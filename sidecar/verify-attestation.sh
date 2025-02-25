#!/bin/bash

mkdir -p /certs
cd /certs

while true; do
    echo "Initializating attestation cycle..."
    
    /usr/local/bin/snpguest report report.bin request-file.txt --random
    /usr/local/bin/snpguest certificates PEM ./
    
    curl --proto '=https' --tlsv1.2 -sSf https://kdsintf.amd.com/vlek/v1/Milan/cert_chain -o cert_chain.pem
    
    VERIFICATION_OUTPUT=$(/usr/local/bin/snpguest verify attestation ./ report.bin 2>&1 || true)
    VERIFICATION_STATUS=$?
    
    REPORT_CONTENT=$(base64 -w0 report.bin)
    CERT_CHAIN_CONTENT=$(cat cert_chain.pem | base64 -w0)
    VLEK_CONTENT=$(cat vlek.pem | base64 -w0)

    cat > /certs/status.json <<EOF
{
    "attestation_status": "$([ $VERIFICATION_STATUS -eq 0 ] && echo 'verified' || echo 'failed')",
    "last_verification": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "verification_output": "$(echo $VERIFICATION_OUTPUT | sed 's/"/\\"/g')",
    "attestation_report": "$REPORT_CONTENT",
    "cert_chain": "$CERT_CHAIN_CONTENT",
    "vlek_certificate": "$VLEK_CONTENT"
}
EOF

    sleep 300
done