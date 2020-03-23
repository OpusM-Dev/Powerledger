pragma solidity ^0.5.0;

library AvlLib {
  function compare(string memory _a, string memory _b) internal pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        require(a.length != 0);
        require(b.length != 0);
        uint length;
        
        if(a.length <= b.length) {
            length = a.length;
        } else {
            length = b.length;
        }
      
        for(uint i=0; i<length; i++) {
            if(a[i] > b[i]) {
                return -1;
            } 
            else if(a[i] < b[i]) {
                return 1;
            }
        }
        if(a.length > b.length) {
            return -1;
        } 
        if(a.length < b.length) {
            return 1;
        }
        return 0;
    }
    
    function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a >= _b ? _a : _b;
    }
}
