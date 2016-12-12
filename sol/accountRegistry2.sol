pragma solidity ^0.4.0;

contract accountRegistry2{
    
    struct acc_det{
        string ac_num;
        string ac_name;
    }
    
    struct t_hashes{
        bytes32 t_hashKey;
    }
    
    mapping(address => acc_det[]) accountsMap;
    mapping(address => t_hashes[]) t_hashMap;

    event NotifyResult(address seller, string result);
        
    function StoreAccount(address seller, string account_number, string account_name) returns(string result) {  
        
        if(msg.sender != seller) {
            throw;
        }
        
        uint accountsMapLen = accountsMap[msg.sender].length;
        
        if (accountsMapLen != 0) {
            for(uint i = 0; i <= accountsMapLen-1; i++) {
                int matchKey = Compare(account_number, accountsMap[msg.sender][i].ac_num);
                if (matchKey == 0){
                    result = "Account already registered";
                    NotifyResult(seller, result);
                    return result;
                }
                else 
                    continue;
            }
        }

        accountsMap[msg.sender].push(acc_det(account_number, account_name));
        result = "Account registered";
        NotifyResult(seller, result);
        return result;
    }
    
    function Authorize(address seller, string buyer_email, string account_number) returns(string result) {

        result = toString(seller);
        NotifyResult(seller, result);

        if(msg.sender != seller) {
            throw;
        }

        bytes32 current_hash;
        uint accountsMapLen = accountsMap[msg.sender].length;
        
        //Seller does not have any accounts, exit
        if (accountsMapLen == 0) { 
            result = "No Accounts";
            NotifyResult(seller, result);
            return result;
         }

        //Loop through seller's accounts
        for(uint i = 0; i <= accountsMapLen-1; i++){
            
            //Match input account number with seller's list
            int matchKey = Compare(account_number, accountsMap[msg.sender][i].ac_num);

            //If match found
            if(matchKey == 0){
                              
                current_hash =  sha3(seller, buyer_email, account_number);
                uint t_hashLen = t_hashMap[msg.sender].length;
                
                t_hashMap[msg.sender].push(t_hashes(current_hash));
                result = "Buyer Authorised";
                NotifyResult(seller, result);
                return result;
            }
        }
        result = "Buyer Not Authorised";
        NotifyResult(seller, result);
        return result; 
    }   
    
    function ViewAccount(address seller, string buyer_email, string account_number) returns(string result) {
        bytes32 current_hash;

        current_hash = sha3(seller, buyer_email, account_number);

        //Seller has not provided any authorisations
        if (t_hashMap[seller].length == 0) { return "No Authorisation"; }

        //Loop through seller's authorisations for a match
        for(uint i = 0; i <= t_hashMap[seller].length - 1; i++) {

            if (current_hash == t_hashMap[seller][i].t_hashKey) {
                result = "Valid account";
                NotifyResult(seller, result);
                return result;
            }            
        }
        result = "Account not Valid";
        NotifyResult(seller, result);
        return result;
    }
    
    function Revoke(address seller, string buyer_email, string account_number) returns(string result) {

        if(msg.sender != seller) {
            throw;
        }

        bytes32 current_hash;
        int accountFound = 0;

        current_hash = sha3(seller, buyer_email, account_number);
        
        //Seller has not provided any authorisations
        if (t_hashMap[seller].length == 0) { 
            result = "No Authorisation to be revoked";
            NotifyResult(seller, result);
            return result;
        } 
        
        //Loop through seller's authorisations for a match
        for(uint i = 0; i <= t_hashMap[seller].length-1; i++) {
            if (current_hash == t_hashMap[seller][i].t_hashKey) {
                t_hashMap[seller][i].t_hashKey = "";
                result = "Authorization revoked";
                NotifyResult(seller, result);
                return result;
            }
        }
        result = "No Authorisation to be revoked";
        NotifyResult(seller, result);
        return result;
    }

    function Compare(string _a, string _b) private returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        
        if (b.length < minLength) 
            minLength = b.length;
        
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    function toString(address x) private returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }
}