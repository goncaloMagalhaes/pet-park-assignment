//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    address owner;
    mapping(AnimalType => uint256) public animalCounts;
    mapping(address => AnimalType) currentBorrowedAnimal;
    mapping(address => uint256) userAge;
    mapping(address => Gender) userGender;

    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        None,
        Male,
        Female
    }

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType animalType, uint256 count) external {
        require(msg.sender == owner, "Only owner can add animals");
        require(animalType != AnimalType.None, "Invalid animal");
        require(count > 0, "Count must be greater than zero");

        animalCounts[animalType] += count;

        emit Added(animalType, count);
    }

    function borrow(uint256 age, Gender gender, AnimalType animal) external {
        require(age > 0, "Age must be greater than zero");
        require(animal != AnimalType.None, "Invalid animal type");
        require(animalCounts[animal] > 0, "Selected animal not available");
        
        require(
            userAge[msg.sender] == 0 || userAge[msg.sender] == age,
            "Invalid Age"
        );
        require(
            userGender[msg.sender] == Gender.None || userGender[msg.sender] == gender,
            "Invalid Gender"
        );
        
        require(
            currentBorrowedAnimal[msg.sender] == AnimalType.None,
            "Already adopted a pet"
        );

        if (userAge[msg.sender] == 0) {
            userAge[msg.sender] = age;
        }
        if (userGender[msg.sender] == Gender.None) {
            userGender[msg.sender] = gender;
        }

        if (gender == Gender.Female && age < 40) {
            require(animal != AnimalType.Cat, "Invalid animal for women under 40");
        }
        if (gender == Gender.Male) {
            require(
                animal == AnimalType.Dog || animal == AnimalType.Fish,
                "Invalid animal for men"
            );
        }

        animalCounts[animal] -= 1;
        currentBorrowedAnimal[msg.sender] = animal;

        emit Borrowed(animal);
    }

    function giveBackAnimal() external {
        require(
            currentBorrowedAnimal[msg.sender] != AnimalType.None,
            "No borrowed pets"
        );

        AnimalType animal = currentBorrowedAnimal[msg.sender];

        animalCounts[animal] += 1;
        currentBorrowedAnimal[msg.sender] = AnimalType.None;

        emit Returned(animal);
    }
}