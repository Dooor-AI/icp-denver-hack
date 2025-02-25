// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/** 
 * @title TokenEscrow
 * @dev Contract for managing native token deposits with admin-controlled withdrawals.
 * Each deposit generates a unique sequential ID and stores user information.
 * Withdrawals are controlled by an admin oracle address for foundation funding.
 */
contract TokenEscrow {
    /// @dev Admin oracle address that controls withdrawals
    address public immutable admin;
    
    /// @dev Total amount of deposits in contract
    uint256 public totalDeposits;
    
    /// @dev Current deposit ID counter, increments with each deposit
    uint256 public currentDepositId;
    
    /// @dev Structure for storing deposit information
    struct Deposit {
        address user;      // Address that made the deposit
        uint256 amount;    // Amount of native tokens deposited
        uint256 timestamp; // Block timestamp of deposit
    }
    
    /// @dev Maps deposit IDs to deposit information
    mapping(uint256 => Deposit) public depositById;
    
    /// @dev Maps user addresses to their deposit IDs
    mapping(address => uint256[]) public userDepositIds;
    
    /// @notice Emitted when a user makes a deposit
    /// @param depositId Unique identifier for the deposit
    /// @param user Address that made the deposit
    /// @param amount Amount of tokens deposited
    /// @param timestamp Block timestamp of deposit
    event Deposited(uint256 indexed depositId, address indexed user, uint256 amount, uint256 timestamp);
    
    /// @notice Emitted when admin withdraws tokens
    /// @param recipient Address receiving the withdrawal
    /// @param amount Amount of tokens withdrawn
    event AdminWithdrawn(address indexed recipient, uint256 amount);
    
    /**
     * @dev Sets the admin oracle address
     * @param _admin Address of the admin oracle that will control withdrawals
     */
    constructor(address _admin) {
        require(_admin != address(0), "Invalid admin address");
        admin = _admin;
    }
    
    /// @dev Ensures only admin oracle can call function
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin oracle can call this");
        _;
    }
    
    /**
     * @notice Allows users to deposit native tokens
     * @dev Generates unique deposit ID and stores deposit information
     */
    function deposit() external payable {
        require(msg.value > 0, "Must deposit some amount");
        
        uint256 depositId = currentDepositId;
        
        depositById[depositId] = Deposit({
            user: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp
        });
        
        userDepositIds[msg.sender].push(depositId);
        
        totalDeposits += msg.value;
        currentDepositId++;
        
        emit Deposited(depositId, msg.sender, msg.value, block.timestamp);
    }
    
    /**
     * @notice Allows admin to withdraw specified amount to recipient
     * @dev Only callable by admin oracle for foundation funding
     * @param amount Amount of tokens to withdraw
     * @param recipient Address receiving the withdrawal
     */
    function adminWithdraw(uint256 amount, address recipient) external onlyAdmin {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= address(this).balance, "Insufficient contract balance");
        require(recipient != address(0), "Invalid recipient address");
        
        totalDeposits -= amount;
        
        (bool success, ) = payable(recipient).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit AdminWithdrawn(recipient, amount);
    }
    
    /**
     * @notice Gets all deposit IDs for a user
     * @param user Address to query
     * @return Array of deposit IDs belonging to the user
     */
    function getUserDepositIds(address user) external view returns (uint256[] memory) {
        return userDepositIds[user];
    }
    
    /**
     * @notice Gets deposit information by ID
     * @param depositId ID of deposit to query
     * @return user Address that made the deposit
     * @return amount Amount of tokens deposited
     * @return timestamp Block timestamp of deposit
     */
    function getDeposit(uint256 depositId) external view returns (address user, uint256 amount, uint256 timestamp) {
        Deposit memory dep = depositById[depositId];
        return (dep.user, dep.amount, dep.timestamp);
    }

    /**
     * @notice Gets current contract balance
     * @return Current balance of native tokens in contract
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}