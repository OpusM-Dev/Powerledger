pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./KeyValueTable.sol";

contract KeyValueTableStore {
    mapping(string=>KeyValueTable) tables;
    string[] tableNames;

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

    function create(
        string _name,
        string _keyColumn
    ) public {
        tables[_name] = new KeyValueTable(
            _name,
            _keyColumn
        );
        tableNames.push(_name);
    }

    function dropTable(
        string _name
    ) public returns (
        string
    ) {
        for(uint i=0; i<tableNames.length; i++) {
            bytes memory tmp = bytes(tableNames[i]);
            require(tmp.length != 0);

            if(keccak256(tableNames[i]) == keccak256(_name)) {
                delete(tableNames[i]);
                delete(tables[_name]);
            }
        }
    }

    function getTableNames() public returns (
        string[]
    ) {
        return tableNames;
    }

}
