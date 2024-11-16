//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract SmartBank {
    
    address payable owner;
    uint public interest;

    address public coffeeTokenAddress;
    address public immutable WETH;
    ISwapRouter public immutable swapRouter;

    // Struct kasutatakse peamiselt selleks, et ühe kasutaja(aadressi) andmed oleks kergesti loetavad contracti küljest ning oleks koondatud ühe objekti alla
    // Kasutajal on tema ethereum deposiit, genereeritud intress, mida ta saab välja võtta otse MetaMask walletisse ning praegune laenu suurus, mida saab samuti
    // otse metamaski kanda.
    struct BankAccount {
        uint depositedEth;
        uint generatedInterest;
        uint currentLoan;
    }

    // kasutaja deponeeritud tokenid on eraldi muutujana ning kasutasin just mapi, sest see on lihtsaim viis, kuidas talletada palju tokeneid on aadressile deponeeritud
    // kasutajate eristamiseks on samuti map, milles aadress on seotud BankAccount structiga (mõtlen structidest kui objektidest)
    mapping(address => uint) public depositedTokens;
    mapping(address => BankAccount) public accounts;

    // constructoris initsialiseeritakse lepingu omanik, keda on vaja, et teha "Panga Omaniku" tegevusi.
    // swapRouter ning WETH on vajalikud valuutavahetuseks, mis ei tööta. Antud väljad sain ma stackoverflowst mingist uniswapi integratsioonist, kuid tööle ma seda ei saanud.
    // Põhjus seisneb ilmselt selles, et uniswapis pole ühtegi märget minu deploytud CoffeeTokenist.
    // 8. punkt koduülesandes on lahendamata, ehk boonuspunktidele ma ei kandideeri aja kokkuhoiu mõttes, ilmselt lahendan selle asja ära vabast ajast natukene hiljem :)
    constructor() payable {
        owner = payable(msg.sender);
        swapRouter = ISwapRouter(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008); // ei oma erilist mõtet, funktsionaalsus katkine
        WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14; // ei oma erilist mõtet, funktsionaalsus katkine. Antud aadress on tegelikult sepolia testneti WETH aadress, see peaks isegi õige olema.
    }

    // Panga kliendi esimene nõue, kus ainult klient saab ethereumi deponeerida. Seda reguleerib require.
    function depositEth() public payable {
        require(msg.sender != owner, "Only the client can deposit ETH!");
        accounts[msg.sender].depositedEth += msg.value;
    }

    // Panga kliendi teine nõue, kus ainult klient saab ethereumi välja võtta contractist. Seda reguleerib samuti require, koos sellega, et kasutaja ei saa välja võtta
    // rohkem kui ta kontoseis contractis. (BankAccount.depositedEth = kontoseis).
    function withdrawEth(uint _amount) public {
        require(msg.sender != owner, "Only the client can withdraw ETH!");
        require(_amount <= accounts[msg.sender].depositedEth, "Can't withdraw more than the bank account balance!");

        accounts[msg.sender].depositedEth -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    // Panga kliendi viies nõue, kus klient saab deponeerida enda aadressiga seotult tokeneid /mapping(address => uint) public depositedTokens;/.
    // CoffeeToken contracti deploysin samuti sepolia testneti CoffeeToken nime all. Töös esitan mõlemad contractid.
    // Tokenite deponeerimiseks on oluline see, et CoffeeToken contractis oleks ära tehtud järgnevad asjad:
            // 1) Kliendi aadressile on CoffeeToken deploy-ja mintinud mingi koguse tokeneid.
            // 2) Klient on oma aadressi alt CoffeeToken contractis "approvenud"-seal selline meetod SmartBank contracti kasutama x arvu tokeneid, muidu tokeneid deponeerida ei saa.
            // 3) SmartBank contractis on Klient määranud ära CoffeeTokeni contracti aadressi, allpool vastav meetod.
    function depositERC20Token(uint _amount) public {
        require(msg.sender != owner, "Only the client can deposit tokens!");

        IERC20 token = IERC20(coffeeTokenAddress);
        require(token.balanceOf(msg.sender) >= _amount, "Not enough token balance!");

        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Token transfer failed!");

        depositedTokens[msg.sender] += _amount;
    }

    // Panga kliendi viies nõue.
    // Tokenite väljavõtmise funktsioon, kus tokeni eemaldamisel SmartBank contractist kuvatakse väljavõetud tokeneid jälle CoffeeToken contractis, ehk siis tokenid lähevad
    // taas tagasi kliendi walletisse.
    function withdrawERC20Token(uint _amount) public {
        require(msg.sender != owner, "Only the client can withdraw tokens!");
        require(depositedTokens[msg.sender] >= _amount, "Can't withdraw more than the token balance!");

        depositedTokens[msg.sender] -= _amount;

        IERC20 token = IERC20(coffeeTokenAddress);
        bool success = token.transfer(msg.sender, _amount);
        
        require(success, "Token transfer failed!");
    }
    
    // Boonusnõue!!!
    // Eksperimendi korras lisasin antud koodijupi stackoverflow erinevatest rubriikidest, mida tõlgendas mulle chatGPT. See ei tööta.
    // Võibolla lisaksin omalt poolt sellise asja, et kui võrrelda ChatGPT oskust kirjutada nt Java koodi versus solidity/blockchain koodi, siis viimasel juhul jääb GPT hätta.
      function swapCoffeeTokenForWETH(uint256 _coffeeTokenAmount) external payable  returns (uint256 _out) {
        IERC20(coffeeTokenAddress).transferFrom(msg.sender, address(this), _coffeeTokenAmount);

        IERC20(coffeeTokenAddress).approve(address(swapRouter), _coffeeTokenAmount);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: coffeeTokenAddress,
                tokenOut: WETH,
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp + 15,
                amountIn: _coffeeTokenAmount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        _out = swapRouter.exactInputSingle(params);
    }

    // Panga kliendi kolmas nõue, kus klient saab enda BankAccount.depositedEth saldolt kanda raha teistele kasutajatele.
    // Antud funktsioonile lisasin ka gas-capi, et testida selle funktsionaalsust. Call meetodit kasutasin sellepärast, et
    // Udemy veebikursusest tulenevalt toodi mitmeid positiivseid aspekte .call eelistamiseks üle .transfer meetodi.
    function makePayment(address payable _to, uint _amount) public {
        require(msg.sender != owner, "Only the client can make payments!");
        require(_amount <= accounts[msg.sender].depositedEth, "Can't send more than your deposited ETH!");

        accounts[msg.sender].depositedEth -= _amount;
        (bool success,) = _to.call{value:_amount, gas:1000000}("");
        require(success, "Aborting, call not successful");
    }

    // Panga omaniku deposiidiga seotud abifunktsioon, kus panga omanik saab sätestada masktava intressi intressimäära. Määr sisestatakse täisnumbrina, näiteks
    // soovides maksta 10% intressi depositedEth pealt, tuleb _interest=10. Seda jagatakse sajaga funktsioonide sees eraldi.
    function setDepositInterest(uint _interest) public {
        require(msg.sender == owner, "Only the owner can set the interest!");
        interest = _interest;
    }

    // Abimeetod selleks, et SmartBank saaks suhelda CoffeToken smart contractiga. Siingi on oluline, et klient ise sätestaks tokeni contracti aadressi.
    function setTokenAddress(address _coffeeTokenAddress) public {
        require(msg.sender != owner, "Only the client can set it's token address!");
        coffeeTokenAddress = _coffeeTokenAddress;
    }

    // Panga omaniku esimene nõue, kus omanik saab sätestatud intressimääraga maksta kliendile intressitulu. Antud väärtus läheb kliendi BankAccount structi kolmandaks ehk generatedInterest väljaks, mida
    // saab klient eraldi kanda enda walletisse.
    function payInterestOnDeposit(address payable _to) public {
        require(msg.sender == owner, "Only the owner can pay interest on deposits!");
        require(interest != 0, "The interest rate has not been set!");

        uint interestAmount = (accounts[_to].depositedEth * interest) / 100;
        
        accounts[_to].generatedInterest += interestAmount;
    }

    // Panga kliendi neljas nõue, kus klient saab panga omaniku makstud intressi kanda enda walletisse.
    function receiveInterestPayment() public {
        require(msg.sender != owner, "Only the client can receive interest!");
        require(accounts[msg.sender].generatedInterest > 0, "No interest accumulated on the deposit, nothing to withdraw!");
        
        uint interestToSendOut = accounts[msg.sender].generatedInterest;
        accounts[msg.sender].generatedInterest = 0;
        payable(msg.sender).transfer(interestToSendOut);
    }

    // Panga omaniku teine nõue, kus omanik saab kindlale kliendile anda laenu. Laenusuurus oleneb otseselt sellest, palju on ETH-i SmartBank contractis (nagu päris pank :D).
    // Lisaks lisasin sellise väikese nüansi, kus pangalaen, mida tuleb tagasi maksta on suurem kui saadud laen. Et pank teeniks vist :D
    function giveLoan(address payable _to, uint _amount) public {
        require(msg.sender == owner, "Only the owner can give loans!");
        require(_amount <= address(this).balance, "Not enough funds in the contract to give the loan!");

        accounts[_to].currentLoan += _amount + (_amount / 6); // SO BANK MAKES BANK
        accounts[_to].depositedEth += _amount;
    }
    
    // Panga kliendi kuues nõue, kus klient saab korvata kogu võlgnevuse, kui tal on depositedEth saldo suurem kui pangalaenu ehk currentLoan saldo.
    // Kui kliendi "pangakaardil" pole piisavalt vahendeid korvatakse täpselt nii suur summa laenust, kui pangakontol on.
    function payOffLoan() public {
        BankAccount storage userAccount = accounts[msg.sender];
        require(userAccount.currentLoan > 0, "No outstanding loan to pay off!");

        uint paymentAmount;

        if (userAccount.depositedEth >= userAccount.currentLoan) {

            paymentAmount = userAccount.currentLoan;
            userAccount.depositedEth -= userAccount.currentLoan;
            userAccount.currentLoan = 0;
        } else {

            paymentAmount = userAccount.depositedEth;
            userAccount.currentLoan -= userAccount.depositedEth;
            userAccount.depositedEth = 0;
        }
    }

    // Receive funktsioon selleks, et saaks kasutada low lever interaction-eid. Ise kasutasin rohkem depositEth varianti.
    receive() external payable {
        depositEth();
     }
}

