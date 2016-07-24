contract token { function transferFrom(address _from, address _to, uint256 _value) {} }

contract toggleCoin {
    /* Public variables of the toggleCoin contract */
    uint public togglesLeft;
    uint public nextTransferTime;
    address public acct1;
    address public acct2;
    token public lochCoin;
    
    /* Private variables of the toggleEther contract */
    address prevSender;
    uint gapInSeconds;
    uint amount = 100;

    /* Contract constructor - called at the time of deployment */
    function toggleCoin(uint _numOfTimes, uint _gapInSeconds, address _receiver, address _addOfLochCoin) {
        acct1 = msg.sender;                    // Creator of contract is acct1
        acct2 = _receiver;                     // Address of acct2
        togglesLeft = _numOfTimes;              // Number of times to perform toggleEther
        gapInSeconds = _gapInSeconds;
        nextTransferTime = now + gapInSeconds * 1 seconds; // Number of seconds between toggleEthers
        lochCoin = token(_addOfLochCoin);
    }

    /* Modifier to check if we have crossed the min wait time */
    modifier afterGap() { 
        if (now <= nextTransferTime) 
            throw;
        _
    }

    /* Perform checks and send Coins */
    function sendCoin() afterGap {
        // Prevents accidental sending of coin to other accounts
        if(msg.sender != acct1 && msg.sender != acct2)
            throw;
        
        // Prevent one sender from sending two in a row
        if(msg.sender == prevSender)
            throw;

        // Prevent sending if we are over the max toggles
        if(togglesLeft < 0)
            throw;
        
        // If sender is acct1
        if(msg.sender == acct1) {
            // Send 100 LochCoins to acct2
            lochCoin.transferFrom(acct1, acct2, amount);
            prevSender = acct1;                    // Set PrevSender to acct1
        }
        // If sender is acct2
        else { 
            // Send 100 LochCoins to acct1
            lochCoin.transferFrom(acct2, acct1, amount);
            prevSender = acct2;                      // Set PrevSender to acct2
        }
        
        togglesLeft--;
        nextTransferTime = now + gapInSeconds * 1 seconds;
    }

    /* Kill the contract */
    function kill() { 
        if (msg.sender == acct1)   //Only creator(acct1) can kill
            selfdestruct(acct1); 
    }

    /* Catch-all */
    function () { throw; }
}