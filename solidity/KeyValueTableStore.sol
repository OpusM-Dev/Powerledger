pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract KeyValueTableStore {
    // Key : Name / Value : CA
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
    
    /**
     * JS에서 create 함수 호출하기 전에 KeyValueTable.sol을 배포하고 나온 CA를 매개변수로 전달해야 한다.
     */
    function create(
        string _name,
        string _address
    ) public {
        bytes memory tmp = bytes(tables[_name]);
        
        require(tmp.length == 0);
        
        tables[_name] = _address;
        tableNames.push(_name);
    }
    
    function dropTable(
        string _name
    ) public returns (
        string
    ) {
        for(uint i=0; i<tableNames.length; i++) {
            if(keccak256(tableNames[i]) == keccak256(_name)) {
                delete(tableNames[i]);
                delete(tables[_name]);
                
                return ("dropTable Success");
            }
        }
        return "dropTable Fail";
    }
    
    function getTableNames() public view returns (
        string[]
    ) {
        return tableNames;
    }
    
}
