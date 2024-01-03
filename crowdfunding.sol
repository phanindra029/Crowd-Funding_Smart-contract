// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding{

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfvoters;
        mapping(address=>bool) voters;
    }
    mapping(address=>uint) public contributors;
    mapping(uint=>Request) public requests;
    uint public numRequests;
    address public manager;
    uint public minimumcontribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfcontributors;


    constructor(uint _target, uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumcontribution=100 wei;
        manager=msg.sender;
    }

    modifier onlymanager(){
        require(msg.sender==manager,"YOU ARE NOT THE MANAGER!!!");
        _;
    }

    function createRequests(string calldata _description,address payable _recipient,uint _value) public onlymanager{
    Request storage newRequest = requests[numRequests];
    numRequests++;
    newRequest.description=_description;
    newRequest.recipient=_recipient;
    newRequest.value=_value;
    newRequest.completed=false;
    newRequest.noOfvoters=0;
    }

    function contribution() public payable {
        require(block.timestamp<deadline,"THE DEADLINE HAS PASSED!!!");
        require(msg.value>=minimumcontribution,"MINIMUM CONTRIBUTION REQUIRED IS 100 wei !!");


        if(contributors[msg.sender]==0){
            noOfcontributors++;
        }

        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }

    function getcontractBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"YOY ARE NOT ELIGBLE FOR REFUND !!");
        require(contributors[msg.sender]>0,"YOU ARE NOT A CONTRIBUTOR !!");
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }


    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"YOU ARE NOT A CONTRIBUTOR !!!");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"YOU HAVE ALREADY VOTED !!!");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfvoters++;
    }


    function makePayment(uint _requestNo) public onlymanager{
        require(raisedAmount>=target,"TARGET IS NOT REACHED!!!");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"THE REQUEST HAS BEEN COMPLETED");
        require(thisRequest.noOfvoters>noOfcontributors/2,"MAJORITY DOESNOT SUPPORT THE REQUEEST!!!");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }

}