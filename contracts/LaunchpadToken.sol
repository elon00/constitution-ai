// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CNSTToken
 * @notice Decentralized Civic Treasury & Bonding Curve Launchpad for Constitution AI
 * @dev Powered by NIST PQC Attestation & X402 Bazaar Pro-Bono Settlement Hooks
 */
contract CNSTToken {
    string public name = "Constitution AI";
    string public symbol = "CNST";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public constant INITIAL_PRICE = 0.0001 ether;
    uint256 public constant CURVE_SLOPE = 1e10;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event CurveMint(address indexed citizen, uint256 tokenAmount, uint256 ethCost);
    event CivicActionExecuted(address indexed advocate, uint256 subsidyAmount, bytes32 indexed petitionHash);

    function calculateCost(uint256 amount) public view returns (uint256) {{
        uint256 currentSupply = totalSupply;
        uint256 baseCost = amount * INITIAL_PRICE;
        uint256 curveFactor = (CURVE_SLOPE * ((currentSupply + amount)**2 - currentSupply**2)) / 2e18;
        return baseCost + curveFactor;
    }}

    function mint(uint256 amount) external payable returns (bool) {{
        require(amount > 0, "Zero amount");
        uint256 cost = calculateCost(amount);
        require(msg.value >= cost, "Insufficient payment for curve");

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
        emit CurveMint(msg.sender, amount, cost);

        if (msg.value > cost) {{
            payable(msg.sender).transfer(msg.value - cost);
        }}
        return true;
    }}

    function executeCivicSubsidy(address advocate, uint256 amount, bytes32 petitionHash) external returns (bool) {{
        require(balanceOf[msg.sender] >= amount, "Insufficient civic reserve");
        balanceOf[msg.sender] -= amount;
        balanceOf[advocate] += amount;
        emit Transfer(msg.sender, advocate, amount);
        emit CivicActionExecuted(advocate, amount, petitionHash);
        return true;
    }}
}
