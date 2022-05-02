// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Lottery {
    uint public start_block;
    address[] public participants;

    event Received(address Sender, uint Value);
    event Fallback(address Sender, uint Value, bytes Data);

    constructor() {
        start_block = block.number;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable{
        emit Fallback(msg.sender, msg.value, msg.data);
    }

    function getAwards() external view returns (uint) {
        return address(this).balance;
    }

    function transferLottery(address to) public returns (bool) {
        for (uint i = 0; i < participants.length; i++) {
            if (participants[i] == msg.sender) {
                participants[i] = to;
                return true;
            }
        }
        return false;
    }

    function buyLottery() public payable {
        require(participants.length <= 10, "Lottery is full");
        require(block.number < start_block + 300, "Lottery has already ended");
        require(msg.value >= 1 ether, "You must send at least 1 ether to participate");
        participants.push(msg.sender);
    }

    function pickWinner(uint winner) public {
        require(winner < participants.length, "Winner is not a participant");
        require(participants.length > 10 || block.number >= start_block + 300, "Lottery has not ended yet");
        address payable winner_address = payable(participants[winner]);
        require(winner_address != address(0), "No winner was picked");
        winner_address.transfer(address(this).balance);
        // (bool success, ) = winner_address.call{value:address(this).balance}("");
        // require(success, "Transfer failed.");
        start_block = block.number;
        delete participants;
    }

    
}