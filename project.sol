// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerToPeerTutoring {

    struct Tutor {
        string name;
        string subject;
        uint ratePerHour; // rate in tokens
        bool isAvailable;
        address payable tutorAddress;
    }

    struct Student {
        string name;
        uint tokenBalance;
        address studentAddress;
    }

    mapping(address => Tutor) public tutors;
    mapping(address => Student) public students;

    event TutorRegistered(address indexed tutorAddress, string name, string subject, uint ratePerHour);
    event StudentRegistered(address indexed studentAddress, string name, uint initialBalance);
    event SessionBooked(address indexed studentAddress, address indexed tutorAddress, uint hour, uint totalCost);
    event TokensTransferred(address indexed from, address indexed to, uint amount);

    function registerTutor(string memory _name, string memory _subject, uint _ratePerHour) public {
        require(bytes(tutors[msg.sender].name).length == 0, "Tutor already registered");

        tutors[msg.sender] = Tutor({
            name: _name,
            subject: _subject,
            ratePerHour: _ratePerHour,
            isAvailable: true,
            tutorAddress: payable(msg.sender)
        });

        emit TutorRegistered(msg.sender, _name, _subject, _ratePerHour);
    }

    function registerStudent(string memory _name, uint _initialBalance) public {
    require(bytes(students[msg.sender].name).length == 0, "Student already registered");

        students[msg.sender] = Student({
            name: _name,
            tokenBalance: _initialBalance,
            studentAddress: msg.sender
        });

        emit StudentRegistered(msg.sender, _name, _initialBalance);
    }

    function bookSession(address _tutorAddress, uint _hours) public {
        Tutor storage tutor = tutors[_tutorAddress];
        Student storage student = students[msg.sender];

        require(tutor.isAvailable, "Tutor is not available");
        require(_hours > 0, "Invalid number of hours");
        uint totalCost = tutor.ratePerHour * _hours;
        require(student.tokenBalance >= totalCost, "Insufficient balance");

        // Transfer tokens
        student.tokenBalance -= totalCost;
        tutor.tutorAddress.transfer(totalCost);

        emit SessionBooked(msg.sender, _tutorAddress, _hours, totalCost);
        emit TokensTransferred(msg.sender, _tutorAddress, totalCost);
    }

    function getTutor(address _tutorAddress) public view returns (string memory name, string memory subject, uint ratePerHour, bool isAvailable) {
        Tutor memory tutor = tutors[_tutorAddress];
        return (tutor.name, tutor.subject, tutor.ratePerHour, tutor.isAvailable);
    }

    function getStudent(address _studentAddress) public view returns (string memory name, uint tokenBalance) {
        Student memory student = students[_studentAddress];
        return (student.name, student.tokenBalance);
    }

    // Allow students to add more tokens to their balance
    function addTokens(uint _amount) public payable {
        Student storage student = students[msg.sender];
        require(bytes(student.name).length != 0, "Student not registered");
        student.tokenBalance += _amount;

        emit TokensTransferred(address(0), msg.sender, _amount); // Emitting event for tokens added
    }
}
