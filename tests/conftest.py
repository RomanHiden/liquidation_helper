#!/usr/bin/python3

import pytest
from brownie import Contract, network
from brownie.network.contract import InterfaceContainer
from brownie.network.state import _add_contract, _remove_contract


@pytest.fixture(scope="module", autouse=True)
def bzx(accounts, 
    interface):
    bzx = Contract.from_abi("bzx", address="0xD8Ee69652E4e4838f2531732a46d1f7F584F0b7f", abi=interface.IBZx.abi, owner=accounts[0])
    return bzx

@pytest.fixture(scope="module", autouse=True)
def liquidator(accounts, Liquidator):
    liquidatorProxy = accounts[0].deploy(Liquidator)
    liquidator = Contract.from_abi("liquidator", address=liquidatorProxy.address, abi=Liquidator.abi, owner=accounts[0])
    return liquidator

