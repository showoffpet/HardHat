// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// custom error
error TaskNotFound();
error NoTaskFound(address user);
error AlreadyCompleted();
error InvalidTaskNumber();

contract ToDoList {
    // create a task
    // get a task that is associated with the user taskId
    // get all task that is associated with user
    // update a task
    // delete a task
    // PENDING TASK IN COMING TUTORIAL
    // revert with taskId not found if a user uses and invalid taskId* ✅
    // should revert with an error if a user tries to update an already updated task state* ✅
    // should revert with an error (no task found) if we try to get task for a user  who hasnt creeated any* ✅
    // handle events emissions for create task, updated task and deleted task
    // talk about gas efficiency*

    struct Task {
        uint256 taskNumber;
        string taskName;
        address owner;
        bool isTaskCompleted;
    }

    Task private task;

    mapping(address => Task[]) private taskList;

    event CreatedTask(
        uint256 taskNumber,
        string indexed taskName,
        address indexed owner,
        bool indexed isTaskCompleted
    );

    event CompletedTask(
        uint256 taskNumber,
        string indexed taskName,
        address indexed owner,
        bool indexed isTaskCompleted
    );

    event DeletedTask(
        uint256 taskNumber,
        string indexed taskName,
        address indexed owner,
        bool indexed isTaskCompleted
    );

    // write functions
    function createTask(uint256 _taskNumber, string memory _taskName) public {
        Task memory newTask = Task({
            taskNumber: _taskNumber,
            taskName: _taskName,
            owner: msg.sender,
            isTaskCompleted: false
        }); // initialized at false at the point of creation
        taskList[msg.sender].push(newTask);
        emit CreatedTask(
            newTask.taskNumber,
            newTask.taskName,
            newTask.owner,
            newTask.isTaskCompleted
        );
    }

    function completed(
        uint256 _taskNumber
    ) public isTaskNumberValid(_taskNumber) {
        // the contract has to go through all the task of the user
        // has to find the particular task that we want to update as completed
        for (uint256 i = 0; i < taskList[msg.sender].length; i++) {
            Task storage currentTask = taskList[msg.sender][i];
            if (currentTask.taskNumber == _taskNumber) {
                if (currentTask.isTaskCompleted) {
                    revert AlreadyCompleted(); //*
                }
                currentTask.isTaskCompleted = true;
                break;
            }
        }
        emit CompletedTask(
            task.taskNumber,
            task.taskName,
            task.owner,
            task.isTaskCompleted
        );
    }

    function deleteTask(
        uint256 _taskNumber
    ) public isTaskNumberValid(_taskNumber) {
        for (uint256 i = 0; i < taskList[msg.sender].length; i++) {
            Task storage currentTask = taskList[msg.sender][i];
            if (currentTask.taskNumber == _taskNumber) {
                taskList[msg.sender][i] = taskList[msg.sender][
                    taskList[msg.sender].length - 1
                ];
                taskList[msg.sender].pop();
                break;
            }
        }
    }

    // read functions
    function getAllTaskByUser(
        address user
    ) public view returns (Task[] memory) {
        if (taskList[user].length == 0) {
            revert NoTaskFound(user);
        }
        return taskList[user]; // array of task that is associated with a user
    }

    function getTaskByNumber(
        uint256 _taskNumber
    ) public view isTaskNumberValid(_taskNumber) returns (Task memory) {
        Task memory currentTask;
        for (uint256 i = 0; i < taskList[msg.sender].length; i++) {
            if (taskList[msg.sender][i].taskNumber == _taskNumber) {
                currentTask = taskList[msg.sender][i];
                break;
            }
        }
        return currentTask;
    }

    modifier isTaskNumberValid(uint256 _taskNumber) {
        bool taskExist = false;
        for (uint256 i = 0; i < taskList[msg.sender].length; i++) {
            if (taskList[msg.sender][i].taskNumber == _taskNumber) {
                taskExist = true;
                break;
            }
        }
        if (!taskExist) {
            revert InvalidTaskNumber();
        }
        _;
    }
}