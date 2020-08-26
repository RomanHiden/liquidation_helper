pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./DydxFlashloaner.sol";
import "./bZxFlashLoaner.sol";
import "./Ownable.sol";
import "./IBZx.sol";

contract Liquidator is DydxFlashloaner, bZxFlashLoaner, Ownable {
    event Logger(uint256 value);

    uint8 public soloFees = 2 wei;
    uint public bZxFeePercentage = 5e16; // 0.05%

    struct CallData {
        address bZxAddress;
        bytes32 loanId;
        address receiver;
        address collateralToken;
        uint256 flashLoanAmount;
        uint256 iniCollateralTokenBal;
    }

    CallData _callData;

    struct CallDataBzx {
        uint256 iniCollateralTokenBal;
        uint256 loanTokenRepayAmount;
    }

    CallDataBzx _callDataBzx;

    function startWithDyDx(
        address dydxSolo,
        address loanToken,
        address collateralToken,
        address bZxAddress,
        bytes32 loanId,
        address receiver,
        uint256 flashLoanAmount
    ) public payable {
        if (IERC20(loanToken).balanceOf(address(this)) < soloFees) {
            IERC20(loanToken).transferFrom(msg.sender, address(this), soloFees);
        }

        _callData = CallData({
            bZxAddress: bZxAddress,
            loanId: loanId,
            receiver: receiver,
            collateralToken: collateralToken,
            flashLoanAmount: flashLoanAmount,
            iniCollateralTokenBal: IERC20(collateralToken).balanceOf(
                address(this)
            )
        });
        initateFlashLoan(dydxSolo, loanToken, flashLoanAmount);
    }

    function afterLoanSteps(address loanedTokenAddress, uint256 repayAmount)
        internal
    {
        repayAmount; // shh
        loanedTokenAddress; // shh

        liquidateBzxLoan(
            _callData.bZxAddress,
            _callData.loanId,
            _callData.receiver,
            _callData.flashLoanAmount
        );

        uint256 finalCollateralTokenBal = IERC20(_callData.collateralToken)
            .balanceOf(address(this));
        require(
            finalCollateralTokenBal >= _callData.iniCollateralTokenBal,
            "Liquidation not profitable"
        );

        transferTokenInternal(
            _callData.collateralToken,
            finalCollateralTokenBal
        );

        // logTokenBalance(loanedTokenAddress);
    }

    function startWithBzx(
        address iToken,
        address loanToken,
        address collateralToken,
        address bZxAddress,
        bytes32 loanId,
        address receiver,
        uint256 flashLoanAmount
    ) public payable {
        uint256 repayAmount = flashLoanAmount.add(
            flashLoanAmount.mul(bZxFeePercentage).div(1e18)
        );
        if (IERC20(loanToken).balanceOf(address(this)) < repayAmount) {
            IERC20(loanToken).transferFrom(msg.sender, address(this), soloFees);
        }

        _callDataBzx = CallDataBzx({
            iniCollateralTokenBal: IERC20(collateralToken).balanceOf(
                address(this)
            ),
            loanTokenRepayAmount: repayAmount
        });
        initiateFlashLoanBzx(
            iToken,
            loanToken,
            collateralToken,
            bZxAddress,
            loanId,
            receiver,
            flashLoanAmount
        );
    }

    function afterLoanStepsBzx(
        address iToken,
        address loanToken,
        address collateralToken,
        address bZxAddress,
        bytes32 loanId,
        address receiver,
        uint256 flashLoanAmount
    ) public {
        liquidateBzxLoan(bZxAddress, loanId, receiver, flashLoanAmount);

        uint256 finalCollateralTokenBal = IERC20(collateralToken).balanceOf(
            address(this)
        );
        require(
            finalCollateralTokenBal >= _callDataBzx.iniCollateralTokenBal,
            "Liquidation not profitable"
        );

        repayFlashLoanBzx(loanToken, iToken, _callDataBzx.loanTokenRepayAmount);
        transferTokenInternal(collateralToken, finalCollateralTokenBal);
    }

    // closeAmount is denominated in loanToken
    function liquidateBzxLoan(
        address bzx,
        bytes32 loanId,
        address receiver,
        uint256 closeAmount
    ) internal {
        (, uint256 seizedAmount, ) = IBZx(bzx).liquidate(
            loanId,
            receiver,
            closeAmount
        );
        require(seizedAmount != 0, "BZX Liquidation Failed");
    }

    // for testing
    function logTokenBalance(address tokenAddress) public returns (uint256) {
        uint256 balOfThis = IERC20(tokenAddress).balanceOf(address(this));
        emit Logger(balOfThis);
        return balOfThis;
    }

    function getWeth(address weth, uint256 amount) internal {
        Weth(weth).deposit.value(amount)();
    }

    function transferEth(uint256 amount)
        public
        onlyOwner
        returns (bool success)
    {
        return transferEthInternal(amount);
    }

    function transferEthInternal(uint256 amount)
        internal
        returns (bool success)
    {
        address(uint160(owner())).transfer(amount);
        return true;
    }

    function transferToken(address token, uint256 amount)
        public
        onlyOwner
        returns (bool success)
    {
        return transferTokenInternal(token, amount);
    }

    function transferTokenInternal(address token, uint256 amount)
        internal
        returns (bool success)
    {
        IERC20(token).transfer(owner(), amount);
        return true;
    }
}

contract Weth {
    function deposit() public payable {}
}
