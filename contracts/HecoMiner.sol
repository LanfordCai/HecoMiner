// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import './IMdexRouter.sol';
import './Ownable.sol';
import './IERC20.sol';
import './SafeMath.sol';
import './ISwapMining.sol';

contract HecoMiner is Ownable {
    using SafeMath for uint256;
    
    address public miner;

    IERC20 public rewardToken;
    
    IMdexRouter public router;
    ISwapMining public swapMining;
    
    IERC20 public token1;
    IERC20 public token2;
    
    uint256 public minProfit;
    // fixCost is used to represent gas fee
    uint256 public fixCost;
    
    constructor(
        IERC20 _token1, 
        IERC20 _token2, 
        IERC20 _rewardToken,
        IMdexRouter _router,
        ISwapMining _swapMining,
        uint256 _minProfit,
        uint256 _fixCost
    ) public {
        miner = address(this);
        token1 = _token1;
        token2 = _token2;
        rewardToken = _rewardToken;
        router = _router;
        swapMining = _swapMining;
        minProfit = _minProfit;
        fixCost = _fixCost;
    }
    
    function approve(IERC20 _token, uint256 _amount) public {
        _token.approve(address(router), _amount);
    }
    
    function approveTokens(
        IERC20 _token1,
        uint256 _amount1,
        IERC20 _token2,
        uint256 _amount2,
        IERC20 _token3,
        uint256 _amount3
    ) public {
        _token1.approve(address(router), _amount1);
        _token2.approve(address(router), _amount2);
        _token3.approve(address(router), _amount3);
    }
    
    function makeMoney(
        uint256 round1AmountIn, 
        uint256 round1AmountMinOut,
        address[] memory round1Path,
        uint256 round2AmountMinOut,
        address[] memory round2Path,
        uint256 deadline,
        address[] memory cashOutPath,
        bool checkProfit
    ) public onlyOwner {
        require(round1AmountIn > 0, 'HecoMiner: invalid round1Amount1');
        require(round1Path.length == round2Path.length, 'HecoMiner: path length inconsistent');
        require(round1Path[0] == round2Path[round2Path.length-1], 'HecoMiner: invalid path');
        require(round1Path[round1Path.length-1] == round2Path[0], 'HecoMiner: invalid path');
        require(cashOutPath[cashOutPath.length-1] == round1Path[0], 'HecoMiner: invalid cashout path');
        
        // buy token2 with token1
        uint[] memory round1Amounts = router.swapExactTokensForTokens(round1AmountIn, round1AmountMinOut, round1Path, miner, deadline);
        uint256 round2AmountIn = round1Amounts[round1Path.length - 1];
        
        // buyback token1 with token2
        uint[] memory round2Amounts = router.swapExactTokensForTokens(round2AmountIn, round2AmountMinOut, round2Path, miner, deadline);
        uint256 amountOut = round2Amounts[round2Path.length - 1];
        // calc the token1 cost after above transactions
        uint256 cost = round1AmountIn.sub(amountOut);
        
        swapMining.takerWithdraw();
        uint256 rewardBalance = rewardToken.balanceOf(miner);
        
        // buy token1 with rewardToken
        uint[] memory cashOutAmounts = router.swapExactTokensForTokens(rewardBalance, 0, cashOutPath, miner, deadline);
        uint256 cashOutToken1 = cashOutAmounts[cashOutPath.length - 1];
        
        if (checkProfit) {
            // if profit is negative, tx will be rollback
            uint256 profit = cashOutToken1.sub(cost).sub(fixCost);
            if (profit < minProfit) {
                revert('No Profit');
            }
        }
    }
    
    function withdraw(IERC20 _token) public onlyOwner {
        uint256 b = _token.balanceOf(miner);
        _token.transfer(owner(), b);
    }
    
    function setToken1(IERC20 _token1) public onlyOwner {
        token1 = _token1;
    }
    
    function setToken2(IERC20 _token2) public onlyOwner {
        token2 = _token2;
    }
    
    function setMinProfit(uint256 _minProfit) public onlyOwner {
        minProfit = _minProfit;
    }
    
    function setFixCost(uint256 _fixCost) public onlyOwner {
        fixCost = _fixCost;
    }
    
    function setRouter(IMdexRouter _router) public onlyOwner {
        router = _router;
    }
    
    function setSwapMining(ISwapMining _mining) public onlyOwner {
        swapMining = _mining;
    }
}