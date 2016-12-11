pragma solidity ^0.4.4;

contract accountRegistry {
    
    struct RegistryEntry {
        address owner;
        string accNumber;
        string accName;
    }

    mapping ( string => RegistryEntry ) m_records;

    function addRecord(string _name, string _accNumber, string _accName) returns (bool _success) {
        if (m_records[_name].owner == 0) {
            m_records[_name].owner = msg.sender;
            m_records[_name].accNumber = _accNumber;
            m_records[_name].accName = _accName;
            _success = true;
        }
        else _success = false;
    }

    function deleteRecord(string _name) {
        if (m_records[_name].owner == msg.sender) {
            m_records[_name].owner = 0;
        }
    }
}