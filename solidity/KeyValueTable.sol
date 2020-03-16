pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./strings.sol";
import { Math } from "./Math.sol";

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

    /////////AVL TREE
    
    struct Node {
        string value;
        string left;
        string right;
        uint256 height;
    }
  
    mapping (string => Node) private tree; 
    string private root = "0";
    uint256 public currentSize = 0;
    
    /////////////
    
    // Store 안에 있는 Table들의 이름을 저장하는 배열
    string[] tableNames;
    // Key : Table's name / Value : KeyColumn
    mapping(string=>string) keyColumns;
    mapping(string=>string) keys;
    // Key : Table's name / Value : 
    mapping(string=>Column[]) columns;
    mapping(string=>Index[]) indices;
    
    mapping(string=>mapping(string=>string)) rows;
    string[] rowNames;
    
    constructor() public {
    // NULL PTR node 
        tree["0"] = Node({
            value: "0",
            left: "0",
            right: "0",
            height: 0
        });
        root = "0";
    }
    function createTable(
        string _name, 
        string _keyColumn
    ) public {
        bool tmp = existTable(_name);
        require(tmp == false);
        tableNames.push(_name);
        keys[_name] = "table:".toSlice().concat(_name.toSlice());
        
        keyColumns[_name] = _keyColumn;
        
        // columns[_name].push(Column(_keyColumn, "string"));
        // indices[_name].push(Index(_name, _keyColumn));
        addColumn(_name, _keyColumn, "string");
        addIndex(_name, _name, _keyColumn);
        keys[_name] = "table:".toSlice().concat(_name.toSlice());
    }
    
    function existTable(
        string _name
    ) private returns (
        bool
    ) {
        for(uint i=0; i<tableNames.length; i++) {
            if(keccak256(tableNames[i]) == keccak256(_name)) {
                return true;
            }
        }
        return false;
    }
    
    function getKeyColumn(
        string _tableName
    ) public view returns (
        string
    ) {
        return keyColumns[_tableName];
    }
    
    ////// 구현
    function createIndexGroupName(
        string _name
    ) public view returns (
        string
    ) {
        string memory s1 = ":index:";
        string memory result = s1.toSlice().concat(_name.toSlice());
        return result;
    }
    
    ////// 구현
    function createRowKey(
        string _keyColumnValue
    ) private view returns (
        string
    ) {
        string memory s1 = ":key:";
        string memory result = s1.toSlice().concat(_keyColumnValue.toSlice());
        return result;
    }
    
    function getModel(
        string _name
    ) public view returns (
        string
    ) {
        string memory s0 = "{\n\t\"name\" : \"";
        string memory s1 = s0.toSlice().concat(_name.toSlice());
        string memory s2 = s1.toSlice().concat("\",\n\t\"columns\" : [ ".toSlice());
        string memory s3 = s2.toSlice().concat(getColumnsInfo(_name).toSlice());
        string memory s4 = s3.toSlice().concat(" ],\n\t\"keyColumn\" : \"".toSlice());
        string memory s5 = s4.toSlice().concat(keyColumns[_name].toSlice());
        string memory s6 = s5.toSlice().concat("\",\n\t\"indices\" : [ ".toSlice());
        string memory s7 = s6.toSlice().concat(getIndexInfo(_name).toSlice());
        string memory s8 = s7.toSlice().concat(" ]\n}".toSlice());
        
        return s8;
    }
    
    function getIndexInfo(
        string _name
    ) private view returns (
        string
    ) {
        string memory result;
        string memory tmp;
        require(indices[_name].length != 0);
        
        for(uint i=0; i<indices[_name].length; i++) {
            string memory s0 = "{\n\t\t\"name\" : \"";
            string memory s1 = s0.toSlice().concat(indices[_name][i].name.toSlice());
            string memory s2 = s1.toSlice().concat("\",\n\t\t\"type\" : \"".toSlice());
            string memory s3 = s2.toSlice().concat(indices[_name][i].column.toSlice());
            string memory s4 = s3.toSlice().concat("\"\n\t}".toSlice());
                
            if( (i + 1) != indices[_name].length ) {
                tmp = s4.toSlice().concat(", ".toSlice());
            } else {
                tmp = s4;
            }
            result = result.toSlice().concat(tmp.toSlice());
        }
        return result;
    }
    
    function getColumnsInfo(
        string _name
    ) public view returns (
        string
    ) {
        string memory result;
        string memory tmp;
        require(columns[_name].length != 0);
        
        for(uint i=0; i<columns[_name].length; i++) {
            string memory s0 = "{\n\t\t\"name\" : \"";
            string memory s1 = s0.toSlice().concat(columns[_name][i].name.toSlice());
            string memory s2 = s1.toSlice().concat("\",\n\t\t\"type\" : \"".toSlice());
            string memory s3 = s2.toSlice().concat(columns[_name][i]._type.toSlice());
            string memory s4 = s3.toSlice().concat("\"\n\t}".toSlice());
            
            if( (i + 1) != columns[_name].length ) {
                tmp = s4.toSlice().concat(", ".toSlice());
            } else {
                tmp = s4;
            }
            result = result.toSlice().concat(tmp.toSlice());
        }
        return result;
    }
    
    //////////////////////////////////////////////////////////////////////////////
    
    function addColumn(
        string _tableName,
        string _columnName,
        string _type
    ) public returns (
        string
    ) {
        require(existColumn(_tableName, _columnName) == false);
        columns[_tableName].push(Column(_columnName,_type));
    }
    
    function existColumn(
        string _tableName,
        string _columnName
    ) private returns (
        bool
    ) {
        for(uint i=0; i<columns[_tableName].length; i++) {
            if(keccak256(columns[_tableName][i].name) == keccak256(_columnName)) {
                return true;
            }
        }
        return false;
    }
    
    function getColumn(
        string _tableName,
        string _columnName
    ) private view returns (
        Column
    ) {
        for(uint i=0; i<columns[_tableName].length; i++) {
            if(keccak256(columns[_tableName][i].name) == keccak256(_columnName)) {
                return columns[_tableName][i];
            }
        }
        return Column("", "");
    }
    
    function isKeyColumn(
        string _tableName,
        string _columnName
    ) private returns (
        bool
    ) {
        if(keccak256(keyColumns[_tableName]) == keccak256(_columnName)) {
            return true;
        }
        return false;
    }
    
    function dropColumn(
        string _tableName,
        string _columnName
    ) public returns (
        string
    ) {
        require(isKeyColumn(_tableName, _columnName) == false);
        
        for(uint i=0; i<columns[_tableName].length; i++) {
            if(keccak256(columns[_tableName][i].name) == keccak256(_columnName)) {
                delete(columns[_tableName][i]);
                return "Drop Column Success";
            }
        }
        return "Drop Column Fail";
    }
    
    //////////////////////////////////////////////////////////////////////////////
    
    function addIndex(
        string _tableName,
        string _indexName,
        string _columnName
    ) public returns (
        string
    ) {
        require(existIndex(_tableName, _indexName) == false);
        indices[_tableName].push(Index(_indexName, _columnName));
    }
    
    function existIndex(
        string _tableName,
        string _indexName
    ) private returns (
        bool
    ) {
        for(uint i=0; i<indices[_tableName].length; i++) {
            if(keccak256(indices[_tableName][i].name) == keccak256(_indexName)) {
                return true;
            }
        }
        return false;
    }
    
    function getIndex(
        string _tableName,
        string _indexName
    ) private view returns (
        Index
    ) {
        for(uint i=0; i<indices[_tableName].length; i++) {
            if(keccak256(indices[_tableName][i].name) == keccak256(_indexName)) {
                return indices[_tableName][i];
            }
        }
        return Index("", "");
    }
    
    function dropIndex(
        string _tableName,
        string _indexName
    ) public returns (
        string
    ) {
        require(isKeyColumn(_tableName, _indexName) == false);
        
        for(uint i=0; i<indices[_tableName].length; i++) {
            if(keccak256(indices[_tableName][i].name) == keccak256(_indexName)) {
                delete(indices[_tableName][i]);
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
        string _name,
        string _column,
        string _value
    ) public returns (
        string
    ) {
        require( existValue(_name, _column) == false );
        rows[_name][_column] = _value;
        rowNames.push(_name);
        return "Add Row Success";
    }
    /**
     * 삭제한다.
     */
    function removeRow(
        string _name
        // string _column
    ) public returns (
        string
    ) {
        // require( existValue(_name) == true);
        // rows[_id] = Row("", "");
        
        for(uint i=0; i<rowNames.length; i++) {
            if(keccak256(rowNames[i]) == keccak256(_name)) {
                delete(rowNames[i]);
                return "Remove Row Success";
            }
        }
        return "Remove Row Fail";
    }
    
    function get(
        string _name,
        string _column
    ) public view returns (
        string
    ) {
        // require( existRow(_name) == true );
        return rows[_name][_column];
    }
    
    function existValue(
        string _name,
        string _column
    ) public view returns (
        bool
    ) {
        bytes memory tmp = bytes(rows[_name][_column]);
        if(tmp.length == 0) {
            return false;
        }
        return true;
    }
    
    /**
     * 있으면 갱신하고, 없으면 에러
     */
    function update(
        string _name,
        string _column,
        string _value
    ) public returns (
        string
    ) {
        require( existValue(_name, _column) == true);
        rows[_name][_column] = _value;
    }
    
    function keies(
        string _name
    ) public view returns (
        string[]
    ) {
        string[] result;
        
        for(uint i=0; i<columns[_name].length; i++) {
            string memory groupName = createRowKey(columns[_name][i].name);
            string memory tmpKey = keys[_name].toSlice().concat(groupName.toSlice());
            result.push(tmpKey);
        }
        
        return result;
    }
    
    function getAllRows(
        string _tableName
    ) public view returns (
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
    
    //////////////////////// AVL tree
    
   
    
    /////////////////////////////////
}
