
// CTR + SHIFT + S -> compile and run script

(async() => {
    let accounts = await web3.eth.getAccounts();
    console.log("Accounts: ", accounts);

    console.log("First acc: ", accounts[0]);
})();