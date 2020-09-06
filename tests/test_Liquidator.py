#!/usr/bin/python3

import pytest
from brownie import Contract, Wei, reverts
from fixedint import * 


def getITokenAddress(underlyingToken):
    itokens = [
            ['1', '0x14094949152EDDBFcd073717200DA82fEd8dC960', '0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359', 'Fulcrum SAI iToken', 'iSAI', '1'],
            ['1', '0x493c57c4763932315a328269e1adad09653b9081', '0x6b175474e89094c44da98b954eedeac495271d0f', 'Fulcrum DAI iToken', 'iDAI', '1'],
            ['1', '0x77f973FCaF871459aa58cd81881Ce453759281bC', '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2', 'Fulcrum ETH iToken', 'iETH', '1'],
            ['1', '0xF013406A0B1d544238083DF0B93ad0d2cBE0f65f', '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48', 'Fulcrum USDC iToken', 'iUSDC', '1'],
            ['1', '0xBA9262578EFef8b3aFf7F60Cd629d6CC8859C8b5', '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599', 'Fulcrum WBTC iToken', 'iWBTC', '1'],
            ['1', '0xA8b65249DE7f85494BC1fe75F525f568aa7dfa39', '0x0d8775f648430679a709e98d2b0cb6250d2887ef', 'Fulcrum BAT iToken', 'iBAT', '1'],
            ['1', '0x1cC9567EA2eB740824a45F8026cCF8e46973234D', '0xdd974d5c2e2928dea5f71b9825b8b646686bd200', 'Fulcrum KNC iToken', 'iKNC', '1'],
            ['1', '0xBd56E9477Fc6997609Cf45F84795eFbDAC642Ff1', '0x1985365e9f78359a9b6ad760e32412f4a445e862', 'Fulcrum REP iToken', 'iREP', '1'],
            ['1', '0xA7Eb2bc82df18013ecC2A6C533fc29446442EDEe', '0xe41d2489571d322189246dafa5ebde1f4699f498', 'Fulcrum ZRX iToken', 'iZRX', '1'],
            ['1', '0x1D496da96caf6b518b133736beca85D5C4F9cBc5', '0x514910771AF9Ca656af840dff83E8264EcF986CA', 'Fulcrum LINK iToken', 'iLINK', '1'],
            ['1', '0x49f4592e641820e928f9919ef4abd92a719b4b49', '0x57ab1ec28d129707052df4df418d58a2d46d5f51', 'Fulcrum sUSD iToken', 'iSUSD', '1'],
            ['1', '0x8326645f3aa6de6420102fdb7da9e3a91855045b', '0xdac17f958d2ee523a2206206994597c13d831ec7', 'Fulcrum Tether iToken', 'iUSDT', '1']
    ]
    for token in itokens:
        bzxToken = token;
        if underlyingToken == bzxToken[2]:
            return bzxToken[1]

def test_marginTradeFromPool_sim(bzx, liquidator, accounts, ERC20):
    loans = bzx.getActiveLoans(0, 10, True)
    print("loans", loans)
    # print("loans", loans)
    loan = loans[0]

    loanId = loan[0]
    loanToken = loan[2]
    collaterlaToken = loan[3]
    maxLiquidatable = loan[13]
    
    iToken = getITokenAddress(loanToken)
    print("iToken", iToken)
    
    ercToken = Contract.from_abi("erc20", address=iToken, abi=ERC20.abi, owner=accounts[0]);
    tx = ercToken.approve(liquidator.address, "20 ether")
    tx.info()

    oneInch = "0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E"
    tx = liquidator.startWithBzx(
        iToken, 
        loanToken, 
        collaterlaToken,
        bzx.address,
        oneInch,
        loanId,
        accounts[0],
        maxLiquidatable
    )
    tx.info()
    assert False