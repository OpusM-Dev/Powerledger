pragma solidity ^0.4.24;
import { Math } from "./Math.sol";

contract AvlTreeString {
struct Node {
        string value;
        string left;
        string right;
        uint256 height;
    }
  
    mapping (string => Node) private tree; 
    string private root = "0";
    uint256 public currentSize = 0;
    
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
    
    function search(string value) public view returns (bool) {
        require(str2Uint(value) > str2Uint("0"));
        if (str2Uint(root) == str2Uint("0")) return false;
        return (str2Uint(tree[value].value) > str2Uint("0"));
    }

    function insert(string value) public returns (string) {
        require(str2Uint(value) > str2Uint("0"));
        root = _insert(root, value);
        currentSize++;
        return root;
    }
  
    //should return bool ?
    function remove(string value) public {
        require(str2Uint(value) > str2Uint("0"));
        root = _remove(root, value);
        currentSize--;
    }

    function getMax() public view returns (string) {
        if (str2Uint(root) == str2Uint("0")) return "0";
        string _root = root;
        while (str2Uint(tree[_root].right) != str2Uint("0")) {
            _root = tree[_root].right;
        }
        return tree[_root].value;
    }
  
    function getMin() public view returns (string) {
        if (str2Uint(root) == str2Uint("0")) return "0";
        string _root = root;
        while (str2Uint(tree[_root].left) != str2Uint("0")) {
            _root = tree[_root].left;
        }
        return tree[_root].value;
    }

    function delMax() public returns (string) {
        if (str2Uint(root) == str2Uint("0")) return "0";
        string _root = root;
        while (str2Uint(tree[_root].right) != str2Uint("0")) {
            _root = tree[_root].right;
        }
        string value = tree[_root].value;
        root = _remove(root, value);
        currentSize--;
        return value;
    }
  
    function delMin() public returns (string) {
        if (str2Uint(root) == str2Uint("0")) return "0";
        string _root = root;
        while (str2Uint(tree[_root].left) != str2Uint("0")) {
            _root = tree[_root].left;
        }
        string value = tree[_root].value;
        root = _remove(root, value);
        currentSize--;
        return value;
    }

    // temp helper function 
    function getChilds(string index) public view  returns (string left, string right) {
        left = tree[index].left;
        right = tree[index].right;
    }

    function getRoot() public view returns(string) {
        return tree[root].value;
    }

    function _insert(string _root, string value) private returns (string) {
        if (str2Uint(_root) == str2Uint("0")) {
            tree[value] = Node({
                value: value,
                left: "0",
                right: "0",
                height: 1
            });
            return value;
        }

        if (str2Uint(value) <= str2Uint(tree[_root].value)) {
            tree[_root].left = _insert(tree[_root].left, value);
        } else {
            tree[_root].right = _insert(tree[_root].right, value);
        }
        return balance(_root);
    }

    function _remove(string _root, string value) private returns (string) {
        string temp;
        if (str2Uint(_root) == str2Uint("0")) {
            return _root;
        }
        if (str2Uint(tree[_root].value) == str2Uint(value)) {
            if (str2Uint(tree[_root].left) == str2Uint("0") || str2Uint(tree[_root].right) == str2Uint("0")) {
                if (str2Uint(tree[_root].left) == str2Uint("0")) {
                    temp = tree[_root].right;
                } else {
                    temp = tree[_root].left;
                }
                tree[_root] = tree["0"];
                return temp;
        } else {
                for (temp = tree[_root].right; str2Uint(tree[temp].left) != str2Uint("0"); temp = tree[temp].left){}
                tree[_root].value = tree[temp].value;
                tree[temp] = tree["0"];
                tree[_root].right = _remove(tree[_root].right, tree[temp].value);
                return balance(_root);
  		    }
  	    }

        if (str2Uint(value) < str2Uint(tree[_root].value)) {
            tree[_root].left = _remove(tree[_root].left, value);
        } else {
            tree[_root].right = _remove(tree[_root].right, value);
        }
        return balance(_root);
    }

    function rotateLeft(string _root) private returns (string)  {
        string temp = tree[_root].left;
        tree[_root].left = tree[temp].right;
        tree[temp].right = _root;
        if (str2Uint(_root) > str2Uint("0")) { 
            tree[_root].height = 1 + Math.max256(tree[tree[temp].left].height, tree[tree[temp].right].height);
        }
        if (str2Uint(temp) > str2Uint("0")) { 
            tree[temp].height = 1 + Math.max256(tree[tree[temp].left].height, tree[tree[temp].right].height);
        }
        return temp;
    }

    function rotateRight (string _root) private returns (string) {
        string temp = tree[_root].right;
        tree[_root].right = tree[temp].left;
        tree[temp].left = _root;
        if (str2Uint(_root) > str2Uint("0")) { 
            tree[_root].height = 1 + Math.max256(tree[tree[_root].left].height, tree[tree[_root].right].height);
        }
        if (str2Uint(temp) > str2Uint("0")) { 
            tree[temp].height = 1 + Math.max256(tree[tree[temp].left].height, tree[tree[temp].right].height);
        }
        return temp;
    }

    function balance(string _root) private returns (string) { 
        if (str2Uint(_root) > str2Uint("0")) { 
            tree[_root].height = 1 + Math.max256(tree[tree[_root].left].height, tree[tree[_root].right].height);
        }
        if (tree[tree[_root].left].height > tree[tree[_root].right].height + 1) {		
            if (tree[tree[tree[_root].left].right].height > tree[tree[tree[_root].left].left].height) {
                tree[_root].left = rotateRight(tree[_root].left);
            }
            return rotateLeft(_root);
        } else if (tree[tree[_root].right].height > tree[tree[_root].left].height + 1) {
        if (tree[tree[tree[_root].right].left].height > tree[tree[tree[_root].right].right].height) {
            tree[_root].right = rotateLeft(tree[_root].right);
        }
        return rotateRight(_root);
        }
        return _root;
    }
  
    function str2Uint(string _b) public view returns (uint256){
        bytes memory b = bytes(_b);
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint(b[i])*(2**(8*(b.length-(i+1))));
        }
        return number;
    }
}
