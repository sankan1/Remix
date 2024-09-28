//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

    //LÜHIKIRJELDUS

    // Funktsionaalsetele nõuetele lisaks implementeerisin konstruktorit kasutades loogika, 
    // kuidas lepingu omanik defineeritakse. Lepingu deploy järel määratakse msg.sender omanikuks 
    // (ehk esimene sender, contract deployer == owner).

    // Defineerisin ühe aktsiavihje saamise funktsiooni, mis otseselt ei täpsusta, et 3 eth maksumus on 
    // tasulisel aktsiavihjel, kuid 3 eth sisestamisel on võimalik mitte-omanik msg.senderil saada tasuline
    // aktsiavihje. 

    // Lisafunktsionaalsusena defineerisin sellise olukorra, kus alla või üle 3 eth saatmisel tagastatakse
    // saadetud eth msg.senderile tagasi.

    // Aktsiavihjete muutmise funktsioonides kontrollitakse , kas msg.sender on omanik, vastandjuhul vihjet muuta ei saa.

    // Lisaks defineerisin contract balance väljavõtmise loogika, vaid juhul kui msg.sender on omanik.

contract StockTip {
    address private owner;

    string private freeStockTip;
    string private paidStockTip;
    // uint public lastFreeStocktipTimestamp;
    // uint public lastPaidStocktipTimestamp;
    // string[] private lastFreeStocktipTimestampArray;
    // string[] private lastPaidStocktipTimestampArray;

    constructor() {
        owner = msg.sender;
    }

    // KAS KASUTAJA SAAB KINDLAKS TEHA, MILLAL AKTSIAVIHJE ON ANTUD?
    // Kui kuupäev/kellaaeg oleks funktsionaalne nõue, saaks lisada antud lahendusse ajatemplid (timestampid). 
    // Näiteks võime lisada muutujad nagu "uint public lastStocktipTimestamp".
    // Timestampi saaks uuendada getStockTip kehas ning tagastada vajadusel uuest funktsioonist või kasutades mingit kollektsiooni, 
    // kus sees on nii aktsiavihje string kui timestamp.

    function getStockTip() public payable returns(string memory) {
        if(msg.sender != owner) {
            if(msg.value == 3 ether) {
                return paidStockTip;
            } else if(msg.value != 3 ether) {
                payable(msg.sender).transfer(msg.value);
                return freeStockTip;
            }
        }

        return "";
    }

    function setOrChangeFreeStockTip(string memory _newFreeTip) public {
        if(msg.sender == owner) {
            // lastFreeStocktipTimestampArray.append(freeStockTip)
            freeStockTip = _newFreeTip;
        }
        // siia lisaks timestamp loogika:
        // lastFreeStocktipTimestamp = block.timestamp
    }

    function setOrChangePaidStockTip(string memory _newPaidTip) public {
        if(msg.sender == owner) {
            // lastPaidStocktipTimestampArray.append(paidStockTip)
            paidStockTip = _newPaidTip;
        }
        // siia lisaks timestamp loogika:
        // lastPaidStocktipTimestamp = block.timestamp
    }

    function withdrawContractBalance() public payable {
        if(msg.sender == owner) {
            payable(owner).transfer(address(this).balance);
        }
    }

    // KAS KASUTAJA SAAB VAADATA VARASEIMAID aktsiavihjeid.
    // Saab, kui implementeerida näiteks aktsiavihjete massiivi talletamise loogika.
    // Näiteks kui omanik muudab tasuta aktsiavihjet, lisatakse enne aktsiavihje muutmist kehtiv aktsiavihje:
    // lastFreeStocktipTimestampArray sisse. Samuti tasulise aktsiavihjega.
    // Tuleks implementeerida selline funktsioon, mis kuvaks kasutajale varasemate aktsiavihjete massiivi sisu, 
    // lisafunktsionaalsusena sellele võiks kasutaja näha ka varasemate massiivielementide timestampe.
    
}