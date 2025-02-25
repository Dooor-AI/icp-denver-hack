from flask import Flask, request, jsonify
import base64
import json
import ssl
import logging

logging.basicConfig(level=logging.DEBUG)
app = Flask(__name__)

def configure_sev_pod(pod_spec):
    """Configura pod para AMD SEV"""
    logging.info("Configurando pod para AMD SEV")
    
    # Adicionar sidecar
    pod_spec['containers'].append({
        'name': 'sev-attestation',
        'image': 'seudockerhub/sev-attestation:latest',
        'ports': [{'containerPort': 8080}],
        'securityContext': {'privileged': True},
        'volumeMounts': [
            {
                'name': 'sev-device',
                'mountPath': '/dev/sev-guest'
            }
        ]
    })

    # Adicionar volumes
    pod_spec['volumes'] = pod_spec.get('volumes', [])
    pod_spec['volumes'].append({
        'name': 'sev-device',
        'hostPath': {
            'path': '/dev/sev-guest',
            'type': 'CharDevice'
        }
    })

@app.route('/mutate', methods=['POST'])
def mutate():
    logging.info("Recebida requisição de mutação")
    request_info = request.json
    
    try:
        pod = request_info['request']['object']
        modified_pod = json.loads(json.dumps(pod))
        configure_sev_pod(modified_pod['spec'])
        
        patch = [{"op": "replace", "path": "/spec", "value": modified_pod['spec']}]
        patch_bytes = json.dumps(patch).encode()
        patch_b64 = base64.b64encode(patch_bytes).decode()
        
        return jsonify({
            "apiVersion": "admission.k8s.io/v1",
            "kind": "AdmissionReview",
            "response": {
                "uid": request_info['request']['uid'],
                "allowed": True,
                "patchType": "JSONPatch",
                "patch": patch_b64
            }
        })
    except Exception as e:
        logging.error(f"Erro: {str(e)}")
        return jsonify({
            "apiVersion": "admission.k8s.io/v1",
            "kind": "AdmissionReview",
            "response": {
                "uid": request_info['request']['uid'],
                "allowed": True
            }
        })

if __name__ == '__main__':
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ssl_context.load_cert_chain('/etc/webhook/certs/tls.crt', '/etc/webhook/certs/tls.key')
    app.run(host='0.0.0.0', port=8443, ssl_context=ssl_context)