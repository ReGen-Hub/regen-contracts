//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Ohji {
    mapping(string => string) user_profile;
    mapping(string => string) chat_history;
    mapping(string => string[]) chat_members;
    mapping(string => string[]) user_chats;

    event UserProfileAdded(bool status, string username, string profileCid);
    event UserProfileRemoved(bool status, string username, string profileCid);
    event ChatHistoryUpdated(bool status, string chatId, string latestChatId);
    event ChatTitleUpdated(bool status, string oldChatId, string newChatId);
    event ChatMembersAdded(bool status, string chatId, string[] latestChatMembers);
    event ChatMemberRemoved(bool status, string chatId, string latestChatMembers);
    event UserChatsUpdated(bool status, string[] allChats);

    function add_user_profile(string memory _username, string memory _profileCid) public {
        user_profile[_username] = _profileCid;
        emit UserProfileAdded(true, _username, _profileCid);
    }

    function remove_user_profile(string memory _username) public {
        string memory ProfileCid = user_profile[_username];
        delete user_profile[_username];
        emit UserProfileRemoved(true, _username, ProfileCid);
    }

    function get_user_profile(string memory _userName) view public returns (string memory profileCid) {
        return user_profile[_userName];
    }

    function get_user_chats(string memory userId) view public returns (string[] memory chatIds) {
        return user_chats[userId];
    }

    function update_chat_history(string memory _chatId, string memory _latestChatCid) public {
        chat_history[_chatId] = _latestChatCid;
        emit ChatHistoryUpdated(true, _chatId, _latestChatCid);
    }

    function get_chat_history(string memory _chatId) view public returns (string memory latestChatCid) {
        return chat_history[_chatId];
    }

    function update_chat_title(string memory _oldChatId, string memory _newChatId) public {
        chat_history[_newChatId] = chat_history[_oldChatId];
        delete chat_history[_oldChatId];

        chat_members[_newChatId] = chat_members[_oldChatId];
        delete chat_members[_oldChatId];

        string[] memory members = chat_members[_newChatId];
        for (uint i = 0; i < members.length-1; i++) {
            string[] memory chats = user_chats[members[i]];
            for(uint j = 0; j < chats.length -1; j++) {
                if (keccak256(abi.encodePacked(chats[j])) == keccak256(abi.encodePacked(_oldChatId))) {
                    delete chats[j];
                    chats[j] = _newChatId;
                }
            }
            user_chats[members[i]] = chats;
        }

        emit ChatTitleUpdated(true, _oldChatId, _newChatId);
    }

    function add_chat_members(string memory _chatId, string[] memory _newChatMembers) public {
        string[] storage current_chat_members = chat_members[_chatId];
        for(uint i = 0; i < _newChatMembers.length; i++) {
            current_chat_members.push(_newChatMembers[i]);
            user_chats[_newChatMembers[i]].push(_chatId);
        }
        chat_members[_chatId] = current_chat_members;
        emit ChatMembersAdded(true, _chatId, chat_members[_chatId]);
    }

    function remove_chat_members(string memory _chatId, string memory _toBeRemoved) public {
        string[] storage current_chat_members = chat_members[_chatId];
        uint index = 0;
        for(uint i = 0; i < current_chat_members.length-1; i++) {
            if(keccak256(abi.encodePacked(current_chat_members[i])) == keccak256(abi.encodePacked(_toBeRemoved))) {
                index = i;
                delete current_chat_members[index];
            }
            current_chat_members[i] = current_chat_members[i+1];
        }
        current_chat_members.pop();
        chat_members[_chatId] = current_chat_members;
        remove_user_chats(_toBeRemoved,_chatId);
        emit ChatMemberRemoved(true, _chatId, _toBeRemoved);
    }

    function remove_user_chats(string memory _user, string memory _chatId) public {
        string[] storage current_chats = user_chats[_user];
        uint index = 0;
        for(uint i = 0; i < current_chats.length-1; i++) {
            if(keccak256(abi.encodePacked(current_chats[i])) == keccak256(abi.encodePacked(_chatId))) {
                index = i;
                delete current_chats[index];
            }
            current_chats[i] = current_chats[i+1];
        }
        current_chats.pop();
        user_chats[_user] = current_chats;
        emit UserChatsUpdated(true, user_chats[_user]);
    }

    function view_chat_members(string memory _chatId) view public returns (string[] memory members) {
        return chat_members[_chatId];
    }
}