contract toggleEther {
    /* Public variables of the toggleEther contract */
    uint public maxToggles;
    uint public nextTransferTime;
    uint public etherLeft;
    uint public amount = 10 finney;
    address public acct1;
    address public acct2;

    /* Private variables of the toggleEther contract */
    address prevSender;
    uint gapInSeconds;

    /* Inform clients about transfer */
    event notifyTransfer(address indexed from, address indexed to, uint value);

    /* Contract constructor - called at the time of deployment */
    function toggleEther(uint8 _numOfTimes, uint8 _gapInSeconds, address _receiver) {
        acct1 = msg.sender;                    // Creator of contract is acct1
        etherLeft = msg.value;
        acct2 = _receiver;                     // Address of acct2
        maxToggles = _numOfTimes;              // Number of times to perform toggleEther
        gapInSeconds = _gapInSeconds;
        nextTransferTime = now + gapInSeconds * 1 seconds; // Number of seconds between toggleEthers
    }

    /* Modifier to check if we have crossed the min wait time */
    modifier afterGap() { 
        if (now <= nextTransferTime) 
            throw;
        _
    }

    /* Perform checks and send Ether */
    function sendEther() afterGap {
        // Prevents accidental sending of ether by other accounts
        if(msg.sender != acct1 || msg.sender != acct2)
            throw;
        
        // Prevent sender from sending two in a row
        if(msg.sender == prevSender)
            throw;

        // Prevent sending if we are over the max toggles
        if(maxToggles < 0)
            throw;
        
        // If sender is acct1
        if(msg.sender == acct1){
            // Send 0.01 Ether to acct2
            if(acct2.send(amount)){
                prevSender = acct1;                    // Set PrevSender to acct1
                notifyTransfer(acct1, acct2, amount);  // Notify anyone listening
            }
        }
        // If sender is acct2
        else{
            // Send 0.01 Ether to acct1
            if(acct1.send(amount)){
                prevSender = acct2;                      // Set PrevSender to acct2
                notifyTransfer(acct2, acct1, amount);    // Notify anyone listening
            }
        }
        
        maxToggles--;
        nextTransferTime = now + gapInSeconds * 1 seconds; 
        etherLeft = this.balance;
    }

    /* Kill the contract */
    function kill() { 
        if (msg.sender == acct1) 
            selfdestruct(acct1); 
    }

    /* Catch-all */
    function () { throw; }
}