pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum, string name, string description, string image, uint target) public {
        address newCampaign = new Campaign(minimum, msg.sender, name, description, image, target);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    struct Feedback {
        string message;
        string imageURL;
        uint timestamp;
    }

    Request[] public requests;
    Feedback[] public feedbackList;
    address public manager;
    uint public minimumContribution;
    string public CampaignName;
    string public CampaignDescription;
    string public imageUrl;
    uint public targetToAchieve;
    address[] public contributors;
    mapping(address => bool) public approvers;
    uint public approversCount;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    modifier onlyInvestors() {
        require(approvers[msg.sender]);
        _;
    }

    constructor(uint minimum, address creator, string name, string description, string image, uint target) public {
        manager = creator;
        minimumContribution = minimum;
        CampaignName = name;
        CampaignDescription = description;
        imageUrl = image;
        targetToAchieve = target;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution, "Contribution amount must be greater than minimum");

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string description, uint value, address recipient) public restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(newRequest);
    }

    function approveRequest(uint index) public {
        require(approvers[msg.sender]);
        require(!requests[index].approvals[msg.sender]);

        requests[index].approvals[msg.sender] = true;
        requests[index].approvalCount++;
    }

    function finalizeRequest(uint index) public restricted {
        require(requests[index].approvalCount > (approversCount / 2));
        require(!requests[index].complete);

        requests[index].recipient.transfer(requests[index].value);
        requests[index].complete = true;
    }

    function submitFeedback(string message, string imageURL) public restricted {
        Feedback memory newFeedback = Feedback({
            message: message,
            imageURL: imageURL,
            timestamp: now
        });

        feedbackList.push(newFeedback);
    }

    function getFeedbackCount() public view onlyInvestors returns (uint) {
        return feedbackList.length;
    }

    function getFeedback(uint index) public view onlyInvestors returns (string, string, uint) {
        require(index < feedbackList.length);
        Feedback memory feedback = feedbackList[index];
        return (feedback.message, feedback.imageURL, feedback.timestamp);
    }

    function getSummary() public view returns (uint, uint, uint, uint, address, string, string, string, uint) {
        return (
            minimumContribution,
            this.balance,
            requests.length,
            approversCount,
            manager,
            CampaignName,
            CampaignDescription,
            imageUrl,
            targetToAchieve
        );
    }

    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }
}