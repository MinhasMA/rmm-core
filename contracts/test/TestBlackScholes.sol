pragma solidity 0.8.0;

/**
 * @title   Black Scholes Math Lib TEST contract
 * @author  Primitive
 * @dev     ONLY FOR TESTING PURPOSES.  
 */

import "../IPrimitiveEngine.sol";
import "../libraries/ABDKMath64x64.sol";
import "../libraries/BlackScholes.sol";
import "../libraries/Calibration.sol";
import "../libraries/ReplicationMath.sol";
import "../libraries/SwapMath.sol";
import "../libraries/Units.sol";

contract TestBlackScholes {
    using Units for *;
    using ReplicationMath for *;
    using BlackScholes for *;
    using CumulativeNormalDistribution for *;

    IPrimitiveEngine public engine;

    constructor(address engine_)  {
        engine = IPrimitiveEngine(engine_);
    }

    // ==== Cumulative Normal Distribution Function Library Entry ====

    function cdf(uint x) public view returns (int128) {
        int128 z = ABDKMath64x64.fromUInt(x);
        return z.getCDF();
    }

    function icdf(uint x) public view returns (int128 y) {
        //int128 p = 0x4000000000000830; // 0.25
        int128 p = x.parseUnits();
        y = p.getInverseCDF();
    }

    // ===== Replication Library Entry =====

    function proportionalVol(bytes32 pid) public view returns (int128) {
        Calibration.Data memory cal = engine.getCalibration(pid);
        return ReplicationMath.getProportionalVolatility(cal.sigma, cal.time);
    }

    function tradingFunction(bytes32 pid) public view returns (int128) {
        Calibration.Data memory cal = engine.getCalibration(pid);
        Reserve.Data memory res = engine.getReserve(pid);
        return ReplicationMath.getTradingFunction(res.RX1, res.liquidity, cal.strike, cal.sigma, cal.time);
    }

    function invariant(bytes32 pid) public view returns (int128) {
        return engine.getInvariantLast(pid);
    }

    // ===== BS Library Entry ====

    function callDelta(Calibration.Data memory self, uint assetPrice) public view returns (int128 y) {
        y = BlackScholes.calculateCallDelta(assetPrice, self.strike, self.sigma, self.time);
    }

    function putDelta(Calibration.Data memory self, uint assetPrice) public view returns (int128 y) {
        y = BlackScholes.calculatePutDelta(assetPrice, self.strike, self.sigma, self.time);
    }

    function d1(Calibration.Data memory self, uint assetPrice) public view returns (int128 y) {
        y = BlackScholes.calculateD1(assetPrice, self.strike, self.sigma, self.time);
    }

    function moneyness(Calibration.Data memory self, uint assetPrice) public view returns (int128 y) {
        y = BlackScholes.logSimpleMoneyness(assetPrice, self.strike);
    }
}
