pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract KeyValueTableStore {
    // Key : Name / Value : Table metadata
    mapping(string=>string) tables;
    // Store 안에 있는 Table들의 이름을 저장하는 배열
    string[] tableNames;
    
    function get(
        string _name
    ) public view returns (
        string
    ) {
        bytes memory tmp = bytes(tables[_name]);
        if(tmp.length != 0) {
            return tables[_name];
        }
        return "";
    }
    
    function set(
        string _name,
        string _data
    ) public {
        bytes memory tmp = bytes(tables[_name]);
        
        require(tmp.length == 0);
        
        tables[_name] = _data;
        tableNames.push(_name);
    }
    
    function remove(
        string _name
    ) public {
        for(uint i=0; i<tableNames.length; i++) {
            if(keccak256(tableNames[i]) == keccak256(_name)) {
                delete(tableNames[i]);
                delete(tables[_name]);
            }
        }
    }
    
    function getTableNames() public view returns (
        string[]
    ) {
        return tableNames;
    }
    
}
