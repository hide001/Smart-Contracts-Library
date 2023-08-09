//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.2; 
import "./DateTime.sol";

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}

// ERC20 Token contract interface

interface Token {
    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);

}

contract Vesting { 

    address public owner;  
    using SafeMath for uint256;

    struct _withdrawdetails{
        uint time;
        uint amount;
    }
    mapping(address => uint) public lockingWallet;
    mapping(address => uint) public VestingTime;
    mapping(address => uint) public unlockDate;
    mapping(address=>mapping(uint=>_withdrawdetails)) public withdrawdetails;
    uint public deployTimestamp;
    address public tokenContract=address(0);
   // uint public onemonth = (31*1*(24*60*60));
    uint public onemonth = 60;
   
     function getYear(uint _timeStemp) internal  pure returns (uint256 year) {
        year = DateTime.getYear(_timeStemp);
    }

    // Years Ends with fab and 1st march we can withdraw maturity amount  
    function timestampFromDateTime(uint _timeStemp)
        internal
        pure
        returns (uint256 timestamp)
    {
        uint year=getYear(_timeStemp);
        return DateTime.timestampFromDateTime(year, 3 , 1, 0, 0, 0);
    }
    
    constructor(address[] memory _wallet,uint[] memory  _tokenamount, uint[] memory  _vestingTime, address _tokenContract) {

       owner=msg.sender;       
       
       tokenContract= _tokenContract; 
       //deployTimestamp = timestampFromDateTime(block.timestamp);
       deployTimestamp = block.timestamp;
       require(_wallet.length == _tokenamount.length && _wallet.length == _vestingTime.length,"Please check parameter values");

       for(uint i=0; i < _wallet.length; i++){      
       
         lockingWallet[_wallet[i]]=_tokenamount[i]; 
         VestingTime[_wallet[i]]=_vestingTime[i];
       //  unlockDate[_wallet[i]] =  timestampFromDateTime(deployTimestamp + (31*_vestingTime[i]*(24*60*60)));
        unlockDate[_wallet[i]] =  deployTimestamp + (600);

        }

        
    } 
 

    event withdraw(address _to, uint _amount);

    
   
   function ViewVestingAmount( address user )public view returns (uint){ 
        uint tempVer = 0; 
             for(uint i=1;i<=12;i++) 
             { 
                 require(unlockDate[user]+onemonth<=block.timestamp,"Unable to Withdraw"); 
                 if(block.timestamp>=unlockDate[user]+(onemonth*i)) 
                 { 
                     if(withdrawdetails[user][i].time==0) 
                     { 
                        tempVer+=lockingWallet[user]/12;                        
                     } 
                 }                                                                                                                                                                                                                          
                 else 
                 { 
                     break; 
                 } 
             } 
             return tempVer; 
    }
    
     function withdrawTokens()public returns (bool){ 
        uint tempVer = 0; 
             for(uint i=1;i<=12;i++) 
             { 
                 require(unlockDate[msg.sender]+onemonth<=block.timestamp,"Unable to Withdraw"); 
                 if(block.timestamp>=unlockDate[msg.sender]+(onemonth*i)) 
                 { 
                     if(withdrawdetails[msg.sender][i].time==0) 
                     { 
                        tempVer+=lockingWallet[msg.sender]/12; 
                        withdrawdetails[msg.sender][i]=_withdrawdetails(block.timestamp,lockingWallet[msg.sender]/12);                       
                     } 
                 }                                                                                                                                                                                                                          
                 else 
                 { 
                     break; 
                 } 
             } 
             Token(tokenContract).transfer(msg.sender, tempVer);
            
             emit withdraw(msg.sender,tempVer);
             return true;
    }
    
 

    
}
