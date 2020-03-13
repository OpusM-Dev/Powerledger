pragma solidity ^0.4.24;

import "./KeyValueTable.sol";

contract KeyValueTableStore {
    mapping(string=>KeyValueTable) tables;
    string[] tableNames;
    
    constructor() {
        
    }
    
    function get(
        string _name
    ) public view returns (
        KeyValueTable
    ) {
        bytes memory tmp = bytes(tables[_name].getName());
        if(tmp.length == 0) {
            return tables[_name];
        }
        return new KeyValueTable("", "");
    }
    
    function set(
        string _name,
        string _keyColumn
    ) public {
        tables[_name] = new KeyValueTable( 
            _name, 
            _keyColumn
        );
        tableNames.push(_name);
    }
}
