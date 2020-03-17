pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract KeyValueTableStore {
    // Key : Name / Value : Table metadata
    mapping(string=>string) private tables;
    // Store 안에 있는 Table들의 이름을 저장하는 배열
    string[] private tableNames;
    
    function get(
        string memory _name
    ) public view returns (
        string memory
    ) {
        bytes memory tmp = bytes(tables[_name]);
        if(tmp.length != 0) {
            return tables[_name];
        }
        return "";
    }
    
    function set(
        string memory _name,
        string memory _data
    ) public {
        bytes memory tmp = bytes(tables[_name]);
        
        require(tmp.length == 0);
        
        tables[_name] = _data;
        tableNames.push(_name);
    }
    
    function remove(
        string memory _name
    ) public {
        for(uint i=0; i<tableNames.length; i++) {
            string memory tmp = tableNames[i];
            if(keccak256(abi.encodePacked(tmp)) == keccak256(abi.encodePacked(_name))) {
                delete(tableNames[i]);
                delete(tables[_name]);
            }
        }
    }
    
    function getTableNames() public view returns (
        string[] memory
    ) {
        return tableNames;
    }
    
}