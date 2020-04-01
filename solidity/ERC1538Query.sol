pragma solidity ^0.5.1;

interface ERC1538Query {
    
  /// notice Gets the total number of functions the transparent contract has.
  /// return The number of functions the transparent contract has,
  ///  not including the fallback function.
  function totalFunctions() external view returns(uint256);
	
  /// notice Gets information about a specific function
  /// dev Throws if `_index` >= `totalFunctions()`
  /// param _index The index position of a function signature that is stored in an array
  /// return The function signature, the function selector and the delegate contract address
  function functionByIndex(uint256 _index) 
    external 
    view 
    returns(
      string memory functionSignature, 
      bytes4 functionId, 
      address delegate
    );
	
  /// notice Checks to see if a function exists
  /// param The function signature to check
  /// return True if the function exists, false otherwise
  function functionExists(string calldata _functionSignature) external view returns(bool);
	
  /// notice Gets all the function signatures of functions supported by the transparent contract
  /// return A string containing a list of function signatures
  function functionSignatures() external view returns(string memory);
	
  /// notice Gets all the function signatures supported by a specific delegate contract
  /// param _delegate The delegate contract address
  /// return A string containing a list of function signatures
  function delegateFunctionSignatures(address _delegate) external view returns(string memory);
	
  /// notice Gets the delegate contract address that supports the given function signature
  /// param The function signature
  /// return The delegate contract address
  function delegateAddress(string calldata _functionSignature) external view returns(address);
	
  /// notice Gets information about a function
  /// dev Throws if no function is found
  /// param _functionId The id of the function to get information about
  /// return The function signature and the contract address
  function functionById(bytes4 _functionId) 
    external 
    view 
    returns(
      string memory signature, 
      address delegate
    );
	
  /// notice Get all the delegate contract addresses used by the transparent contract
  /// return An array of all delegate contract addresses
  function delegateAddresses() external view returns(address[] memory);
}
