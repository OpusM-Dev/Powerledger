pragma solidity ^0.5.0;

import { Math } from "./Math.sol";
import { AvlLib } from "./AvlLib.sol";
import "./strings.sol";

contract AvlTreeString {
    using strings for *;
    
    struct Node {
        string value;
        string left;
        string right;
        uint256 height;
    }
  
    // Table / Column / Row 
    mapping(string => mapping (string => Node)) private tree;
    mapping(string => string) root;
    uint256 public currentSize = 0;

    function create(
        string memory _tableName,
        string memory _columnName,
        string memory _rowName
    ) public {
        string memory key = getKey(
            _tableName,
            _columnName,
            _rowName
        );
        
        tree[key]["0"] = Node({
            value: "0",
            left: "0",
            right: "0",
            height: 0
        });
        root[key] = "0";
    }
    
    function getKey(
        string memory _tableName,
        string memory _columnName,
        string memory _rowName
    ) private view returns (
        string memory
    ) {
        string memory s1 = _tableName.toSlice().concat(":".toSlice());
        string memory s2 = s1.toSlice().concat(_columnName.toSlice());
        string memory s3 = s2.toSlice().concat(":".toSlice());
        string memory s4 = s3.toSlice().concat(_rowName.toSlice());
        
        return s4;
    }
    
    function search(
        string memory _tableName,
        string memory _columnName,
        string memory _rowName,
        string memory value
    ) public view returns (
        bool
    ) {
        require(AvlLib.compare(value, "0") < 0);
        string memory key = getKey(
            _tableName,
            _columnName,
            _rowName
        );
        if (AvlLib.compare(root[key], "0") == 0) return false;
    
        int temp = AvlLib.compare(tree[key][value].value, "0");
    
        if(temp < 0) {
            return true;
        }
        return false;
    }

    function insert(
        string memory _tableName,
        string memory _columnName,
        string memory _rowName,
        string memory value
    ) public returns (
        string memory
    ) {
        require(AvlLib.compare(value, "0") < 0);
        string memory key = getKey(
            _tableName,
            _columnName,
            _rowName
        );
        root[key] = _insert(
            key,
            root[key], 
            value
        );
        currentSize++;
        return root[key];
    }
  
    function remove(
        string memory _tableName,
        string memory _columnName,
        string memory _rowName,
        string memory value
    ) public {
        require(AvlLib.compare(value, "0") < 0);
        string memory key = getKey(
            _tableName,
            _columnName,
            _rowName
        );
        root[key] = _remove(
            key,
            root[key], 
            value
        );
        currentSize--;
    }
  
    function getChilds(
        string memory _tableName,
        string memory _columnName,
        string memory _rowName,
        string memory index
    ) public view  returns (
        string memory left, 
        string memory right
    ) {
        string memory key = getKey(
            _tableName,
            _columnName,
            _rowName
        );
        left = tree[key][index].left;
        right = tree[key][index].right;
    }

    function getRoot(
        string memory _tableName,
        string memory _columnName,
        string memory _rowName
    ) public view returns(
        string memory
    ) {
        string memory key = getKey(
            _tableName,
            _columnName,
            _rowName
        );
        return tree[key][root[key]].value;
    }

    function _insert(
        string memory _key,
        string memory _root, 
        string memory value
    ) private returns (
        string memory
    ) {
        if (AvlLib.compare(_root, "0") == 0) {
            tree[_key][value] = Node({
                value: value,
                left: "0",
                right: "0",
                height: 1
            });
            return value;
        }

        if (AvlLib.compare(value, tree[_key][_root].value) >= 0) {
            tree[_key][_root].left = _insert(
                _key,
                tree[_key][_root].left, 
                value
            );
        } else {
            tree[_key][_root].right = _insert(
                _key,
                tree[_key][_root].right, 
                value
            );
        }
        return balance(
            _key,
            _root
        );
    }

    function _remove(
        string memory _key,
        string memory _root, 
        string memory value
    ) private returns (
        string memory
    ) {
        string memory temp;
        if (AvlLib.compare(_root, "0") == 0) {
            return _root;
        }
        if (AvlLib.compare(tree[_key][_root].value, value) == 0) {
            if (AvlLib.compare(tree[_key][_root].left, "0") == 0 || AvlLib.compare(tree[_key][_root].right, "0") == 0) {
                if (AvlLib.compare(tree[_key][_root].left, "0") == 0) {
                    temp = tree[_key][_root].right;
                } else {
                temp = tree[_key][_root].left;
                }
                tree[_key][_root] = tree[_key]["0"];
                return temp;
            } else {
                for (temp = tree[_key][_root].right; AvlLib.compare(tree[_key][temp].left, "0") != 0; temp = tree[_key][temp].left){}
                tree[_key][_root].value = tree[_key][temp].value;
                tree[_key][temp] = tree[_key]["0"];
                tree[_key][_root].right = _remove(
                    _key,
                    tree[_key][_root].right, 
                    tree[_key][temp].value
                );
                return balance(
                    _key,
                    _root
                );
      		}
      	}

        if (AvlLib.compare(value, tree[_key][_root].value) > 0) {
            tree[_key][_root].left = _remove(
                _key,
                tree[_key][_root].left, 
                value
            );
        } else {
            tree[_key][_root].right = _remove(
                _key,
                tree[_key][_root].right, 
                value
            );
        }
        return balance(
            _key,
            _root
        );
    }

    function rotateLeft(
        string memory _key,
        string memory _root
    ) private returns (
        string memory
    )  {
        string memory temp = tree[_key][_root].left;
        tree[_key][_root].left = tree[_key][temp].right;
        tree[_key][temp].right = _root;
        if (AvlLib.compare(_root, "0") < 0) { 
            tree[_key][_root].height = 1 + Math.max256(
                tree[_key][tree[_key][_root].left].height, 
                tree[_key][tree[_key][_root].right].height
            );
        }
        if (AvlLib.compare(temp, "0") < 0) { 
            tree[_key][temp].height = 1 + Math.max256(
                tree[_key][tree[_key][temp].left].height, 
                tree[_key][tree[_key][temp].right].height
            );
        }
        return temp;
    }

    function rotateRight (
        string memory _key,
        string memory _root
    ) private returns (
        string memory
    ) {
        string memory temp = tree[_key][_root].right;
        tree[_key][_root].right = tree[_key][temp].left;
        tree[_key][temp].left = _root;
        if (AvlLib.compare(_root, "0") < 0) { 
            tree[_key][_root].height = 1 + Math.max256(
                tree[_key][tree[_key][_root].left].height, 
                tree[_key][tree[_key][_root].right].height
            );
        }
        if (AvlLib.compare(temp, "0") < 0) { 
            tree[_key][temp].height = 1 + Math.max256(
                tree[_key][tree[_key][temp].left].height, 
                tree[_key][tree[_key][temp].right].height
            );
        }
        return temp;
    }

    function balance(
        string memory _key,
        string memory _root
    ) private returns (
        string memory
    ) {
        if (AvlLib.compare(_root, "0") < 0) {
            tree[_key][_root].height = 1 + Math.max256(
                tree[_key][tree[_key][_root].left].height, 
                tree[_key][tree[_key][_root].right].height
            );
        }
        if (tree[_key][tree[_key][_root].left].height > tree[_key][tree[_key][_root].right].height + 1) {		
            if (tree[_key][tree[_key][tree[_key][_root].left].right].height > tree[_key][tree[_key][tree[_key][_root].left].left].height) {
                tree[_key][_root].left = rotateRight(
                    _key,
                    tree[_key][_root].left
                );
            }
            return rotateLeft(
                _key,
                _root
            );
        } else if (tree[_key][tree[_key][_root].right].height > tree[_key][tree[_key][_root].left].height + 1) {
            if (tree[_key][tree[_key][tree[_key][_root].right].left].height > tree[_key][tree[_key][tree[_key][_root].right].right].height) {
                tree[_key][_root].right = rotateLeft(
                    _key,
                    tree[_key][_root].right
                );
            }
            return rotateRight(
                _key,
                _root
            );
        }
        return _root;
    }
}