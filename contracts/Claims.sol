pragma solidity 0.5.9;

/*
* @Author Flash
* Source at https://github.com/Flash-Git/Claims/tree/master/contracts
*/

/*
* @Author Flash
* @title Claims
*
* @dev Allows anyone to make claims on the Ethereum blockchain
*/

contract Claims {
  event ClaimMade(address indexed claimer, uint32 indexed id, string indexed claim);
  event ClaimRetracted(address indexed claimer, uint32 indexed id, string indexed claim, uint32 retractCount);
  
  mapping(address => Profile) profiles;
  
  struct Profile {
    mapping(uint32 => Claim) claims;    
    uint32 retractCount;
    uint32 count;
  }
  
  struct Claim {
    string claim;
    bool retracted;
  }
  
  function() external {
    revert("Does not accept Ether");
  }
  
  function getClaim(address _address, uint32 _id) public view returns(string memory) {
    Profile storage profile = profiles[_address];
    require(profile.count > _id, "Claim doesn't exist");
    
    if(profile.claims[_id].retracted){
      return "Retracted";
    }
    return profile.claims[_id].claim;
  }
  
  function getClaimCount(address _address) public view returns(uint32) {
    return profiles[_address].count;
  }
  
  function getRetractCount(address _address) public view returns(uint32) {
    return profiles[_address].retractCount;
  }
  
  function makeClaim(string memory _claim) public {
    require(bytes(_claim).length > 3, "Claim is not long enough");
    require(bytes(_claim).length < 1000, "Claim is too long");
    
    Profile storage profile = profiles[msg.sender];
    Claim storage claim = profile.claims[profile.count];
    
    claim.claim = _claim;
    emit ClaimMade(msg.sender, profile.count++, _claim);
  }
  
  function retractClaim(uint32 _id) public {
    Profile storage profile = profiles[msg.sender];
    require(profile.count > _id, "Claim doesn't exist");
    Claim storage claim = profile.claims[_id];
    require(!claim.retracted, "Claim already retracted");
    
    claim.retracted = true;
    emit ClaimRetracted(msg.sender, _id, claim.claim, profile.retractCount++);
  }
}
