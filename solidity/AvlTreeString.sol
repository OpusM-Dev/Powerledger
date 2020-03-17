pragma solidity ^0.5.0;

import { Math } from "./Math.sol";
import { AvlLib } from "./AvlLib.sol";

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
    tree["0"] = Node({
      value: "0",
      left: "0",
      right: "0",
      height: 0
      });
    root = "0";
  }
    
  function search(string memory value) public view returns (bool) {
    require(AvlLib.compare(value, "0") < 0);
    if (AvlLib.compare(root, "0") == 0) return false;
    
    int temp = AvlLib.compare(tree[value].value, "0");
    
    if(temp < 0) {
        return true;
    }
    return false;
  }

  function insert(string memory value) public returns (string memory) {
    require(AvlLib.compare(value, "0") < 0);
    root = _insert(root, value);
    currentSize++;
    return root;
  }
  
  function remove(string memory value) public {
    require(AvlLib.compare(value, "0") < 0);
    root = _remove(root, value);
    currentSize--;
  }
  
  function getChilds(string memory index) public view  returns (string memory left, string memory right) {
    left = tree[index].left;
    right = tree[index].right;
  }

  function getRoot() public view returns(string memory) {
    return tree[root].value;
  }

  function _insert(string memory _root, string memory value) private returns (string memory) {
    if (AvlLib.compare(_root, "0") == 0) {
      tree[value] = Node({
        value: value,
        left: "0",
        right: "0",
        height: 1
      });
      return value;
    }

    if (AvlLib.compare(value, tree[_root].value) >= 0) {
      tree[_root].left = _insert(tree[_root].left, value);
    } else {
      tree[_root].right = _insert(tree[_root].right, value);
    }
    return balance(_root);
  }

  function _remove(string memory _root, string memory value) private returns (string memory) {
    string memory temp;
    if (AvlLib.compare(_root, "0") == 0) {
      return _root;
    }
    if (AvlLib.compare(tree[_root].value, value) == 0) {
      if (AvlLib.compare(tree[_root].left, "0") == 0 || AvlLib.compare(tree[_root].right, "0") == 0) {
        if (AvlLib.compare(tree[_root].left, "0") == 0) {
          temp = tree[_root].right;
        } else {
          temp = tree[_root].left;
        }
        tree[_root] = tree["0"];
        return temp;
      } else {
        for (temp = tree[_root].right; AvlLib.compare(tree[temp].left, "0") != 0; temp = tree[temp].left){}
        tree[_root].value = tree[temp].value;
        tree[temp] = tree["0"];
        tree[_root].right = _remove(tree[_root].right, tree[temp].value);
        return balance(_root);
  		}
  	}

    if (AvlLib.compare(value, tree[_root].value) > 0) {
      tree[_root].left = _remove(tree[_root].left, value);
    } else {
      tree[_root].right = _remove(tree[_root].right, value);
    }
    return balance(_root);
  }

  function rotateLeft(string memory _root) private returns (string memory)  {
    string memory temp = tree[_root].left;
    tree[_root].left = tree[temp].right;
    tree[temp].right = _root;
    if (AvlLib.compare(_root, "0") < 0) { 
      tree[_root].height = 1 + Math.max256(tree[tree[_root].left].height, tree[tree[_root].right].height);
    }
    if (AvlLib.compare(temp, "0") < 0) { 
      tree[temp].height = 1 + Math.max256(tree[tree[temp].left].height, tree[tree[temp].right].height);
    }
    return temp;
  }

  function rotateRight (string memory _root) private returns (string memory) {
    string memory temp = tree[_root].right;
    tree[_root].right = tree[temp].left;
    tree[temp].left = _root;
    if (AvlLib.compare(_root, "0") < 0) { 
      tree[_root].height = 1 + Math.max256(tree[tree[_root].left].height, tree[tree[_root].right].height);
    }
    if (AvlLib.compare(temp, "0") < 0) { 
      tree[temp].height = 1 + Math.max256(tree[tree[temp].left].height, tree[tree[temp].right].height);
    }
    return temp;
  }

  function balance(string memory _root) private returns (string memory) { 
    if (AvlLib.compare(_root, "0") < 0) {
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
}