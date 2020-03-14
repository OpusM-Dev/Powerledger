pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./strings.sol";

contract KeyValueTable {
    using strings for *;
    
    struct Column {
        string name;
        string _type;
    }
    
    struct Index {
        string name;
        string column;
    }
    
    struct Row {
        string name;
        string value;
    }
    
    mapping(string=>Row) rows;
    string[] rowNames;
    
    string name;
    string keyColumn;
    
    Column[] columns;
    Index[] indices;
    
    string public key;
    
    constructor(string _name, string _keyColumn) {
        key = "table:".toSlice().concat(_name.toSlice());
        name = _name;
        keyColumn = _keyColumn;
        columns.push(Column(_keyColumn, "string"));
    }
    
    function getName() public returns (
        string
    ) {
        return name;
    }
    
    function getKeyColumn() public returns (
        string
    ) {
        return keyColumn;
    }
    
    function createIndexGroupName(
        string _name
    ) public view returns (
        string
    ) {
        string memory s1 = ":index:";
        string memory result = s1.toSlice().concat(_name.toSlice());
        return result;
    }
    
    function createRowKey(
        string _keyColumnValue
    ) public view returns (
        string
    ) {
        string memory s1 = ":key:";
        string memory result = s1.toSlice().concat(_keyColumnValue.toSlice());
        return result;
    }
    
    function getModel() public view returns (
        string
    ) {
        string memory s0 = "{\n\t\"name\" : \"";
        string memory s1 = s0.toSlice().concat(name.toSlice());
        string memory s2 = s1.toSlice().concat("\",\n\t\"columns\" : [ ".toSlice());
        string memory s3 = s2.toSlice().concat(getColumnsInfo().toSlice());
        string memory s4 = s3.toSlice().concat(" ],\n\t\"keyColumn\" : \"".toSlice());
        string memory s5 = s4.toSlice().concat(keyColumn.toSlice());
        string memory s6 = s5.toSlice().concat("\",\n\t\"indices\" : [ ".toSlice());
        string memory s7 = s6.toSlice().concat(getIndexInfo().toSlice());
        string memory s8 = s7.toSlice().concat(" ]\n}".toSlice());
        
        return s8;
    }
    
    function getIndexInfo() private view returns (
        string
    ) {
        string memory result;
        string memory tmp;
        if(indices.length == 0) {
            return "";
        }
        for(uint i=0; i<indices.length; i++) {
            if(isNullIndex(indices[i].name) == false) {
                string memory s0 = "{\n\t\t\"name\" : \"";
                string memory s1 = s0.toSlice().concat(indices[i].name.toSlice());
                string memory s2 = s1.toSlice().concat("\",\n\t\t\"type\" : \"".toSlice());
                string memory s3 = s2.toSlice().concat(indices[i].column.toSlice());
                string memory s4 = s3.toSlice().concat("\"\n\t}".toSlice());
            
                if( (i + 1) != indices.length ) {
                    tmp = s4.toSlice().concat(", ".toSlice());
                } else {
                    tmp = s4;
                }
                result = result.toSlice().concat(tmp.toSlice());
            }
        }
        return result;
    }
    
    function getColumnsInfo() private view returns (
        string
    ) {
        string memory result;
        string memory tmp;
        if(columns.length == 0) {
            return "";
        }
        for(uint i=0; i<columns.length; i++) {
            if(isNullColumn(columns[i].name) == false) {
                string memory s0 = "{\n\t\t\"name\" : \"";
                string memory s1 = s0.toSlice().concat(columns[i].name.toSlice());
                string memory s2 = s1.toSlice().concat("\",\n\t\t\"type\" : \"".toSlice());
                string memory s3 = s2.toSlice().concat(columns[i]._type.toSlice());
                string memory s4 = s3.toSlice().concat("\"\n\t}".toSlice());
            
                if( (i + 1) != columns.length ) {
                    tmp = s4.toSlice().concat(", ".toSlice());
                } else {
                    tmp = s4;
                }
                result = result.toSlice().concat(tmp.toSlice());
            }
        }
        return result;
    }
    
    function create() public {
        addColumn(keyColumn, "string");
        addIndex(name, keyColumn);
    }
    
    //////////////////////////////////////////////////////////////////////////////
    
    function addColumn(
        string _name,
        string _type
    ) public returns (
        string
    ) {
        require(existColumn(_name) == false);
        columns.push(Column(_name,_type));
    }
    
    function existColumn(
        string _name
    ) private returns (
        bool
    ) {
        for(uint i=0; i<columns.length; i++) {
            if(keccak256(columns[i].name) == keccak256(_name)) {
                return true;
            }
        }
        return false;
    }
    
    function isNullColumn(
        string _name
    ) private view returns (
        bool
    ) {
        Column memory tmpColumn = getColumn(_name);
        bytes memory tmp = bytes(tmpColumn.name);
        if(tmp.length == 0) {
            return true;
        }
        return false;
    }
    
    function getColumn(
        string _name
    ) private view returns (
        Column
    ) {
        for(uint i=0; i<columns.length; i++) {
            if(keccak256(columns[i].name) == keccak256(_name)) {
                return columns[i];
            }
        }
        return Column("", "");
    }
    
    function dropColumn(
        string _name
    ) public returns (
        string
    ) {
        for(uint i=0; i<columns.length; i++) {
            if(keccak256(columns[i].name) == keccak256(_name)) {
                delete(columns[i]);
                return "Drop Column Success";
            }
        }
        return "Drop Column Fail";
    }
    
    //////////////////////////////////////////////////////////////////////////////
    
    function addIndex(
        string _name,
        string _column
    ) public returns (
        string
    ) {
        require(existIndex(_name) == false);
        indices.push(Index(_name, _column));
    }
    
    function existIndex(
        string _name
    ) private returns (
        bool
    ) {
        for(uint i=0; i<indices.length; i++) {
            if(keccak256(indices[i].name) == keccak256(_name)) {
                return true;
            }
        }
        return false;
    }
    
    function isNullIndex(
        string _name
    ) public view returns (
        bool
    ) {
        Index memory tmpIndex = getIndex(_name);
        bytes memory tmp = bytes(tmpIndex.name);
        if(tmp.length == 0) {
            return true;
        }
        return false;
    }
    
    function getIndex(
        string _name
    ) private view returns (
        Index
    ) {
        for(uint i=0; i<indices.length; i++) {
            if(keccak256(indices[i].name) == keccak256(_name)) {
                return indices[i];
            }
        }
        return Index("", "");
    }
    
    function dropIndex(
        string _name,
        string _column
    ) public returns (
        string
    ) {
        for(uint i=0; i<indices.length; i++) {
            if(keccak256(indices[i].name) == keccak256(_name)) {
                delete(indices[i]);
                return "Drop Index success";
            }
        }
        return "Drop Index Fail";
    }
    //////////////////////ROW
    /**
     * 없으면 추가하고, 있으면 에러
     */
    function add(
        string _id,
        string _column,
        string _value
    ) public returns (
        string
    ) {
        require( existRow(_id) == false );
        rows[_id] = Row(_column, _value);
        rowNames.push(_id);
        return "Add Row Success";
    }
    /**
     * 삭제한다.
     */
    function remove(
        string _id
    ) public returns (
        string
    ) {
        require( existRow(_id) == true);
        rows[_id] = Row("", "");
        
        for(uint i=0; i<rowNames.length; i++) {
            if(keccak256(rowNames[i]) == keccak256(_id)) {
                delete(rowNames[i]);
                return "Remove Row Success";
            }
        }
        return "Remove Row Fail";
    }
    
    function get(
        string _id
    ) public view returns (
        string,
        string
    ) {
        require( existRow(_id) == true );
        return (rows[_id].name, rows[_id].value);
    }
    
    function existRow(
        string _id
    ) public view returns (
        bool
    ) {
        bytes memory tmp = bytes(rows[_id].name);
        if(tmp.length == 0) {
            return false;
        }
        return true;
    }
    
    /**
     * 있으면 갱신하고, 없으면 에러
     */
    function update(
        string _id,
        string _value
    ) public returns (
        string
    ) {
        require( existRow(_id) == true);
        rows[_id] = Row(_id, _value);
    }
    
    function keys() public view returns (
        string[]
    ) {
        string[] result;
        
        for(uint i=0; i<columns.length; i++) {
            string memory groupName = createRowKey(columns[i].name);
            string memory tmpKey = key.toSlice().concat(groupName.toSlice());
            result.push(tmpKey);
        }
        
        return result;
    }
    
    function getAllRows() public view returns (
        string[] // Row[]
    ) {
        // string memory rowKey = createRowKey(key);
        // return rowKey;
    }
    ///////////////////////검색/////////
    ////////////////////////////////////
    // function findBy(
    //     string _column,
    //     ValueRange[] _range
    // ) public returns (
    //     Iterator<Row>
    // ) {
        
    // }
    
    // function findWithIndex(
    //     Index _index, 
    //     ValueRange[] _range
    // ) public returns (
    //     Iterator<Row>
    // ) {
        
    // }
    
    // function findWithoutIndex(
    //     string _column,
    //     ValueRange[] _range
    // ) public returns (
    //     Iterator<Row>
    // ) {
        
    // }
    
    // function updateTableMetadata()
    ////////////////////////////////////
    function addRowToIndex(
        // Row _row, 
        // TableModel _tableModel
    ) public {
        
    }
    
    function removeRowFromIndex(
        // Row _row,
        // TableModel _tableModel
    ) public {
        
    }
    
}
