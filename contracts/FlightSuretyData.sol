// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 < 0.9.0;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

     address private contractOwner;          // Account used to deploy contract
    bool private operational = true;        // Blocks all state changes throughout the contract if false

    enum AirlineStatus {
        Init,
        Registered,
        Funded
    }

    struct Airline {
        AirlineStatus status;
        string name;
        uint256 balance;
        mapping(address => bool) voters;
        uint256 votes;
    }

    mapping(address => Airline) private airlines;
    uint256 airlinesRegistered;

    enum FlightStatus {
        Unknown,
        OnTime,
        Late
    }

    struct Flight {
        FlightStatus status;
        address airline;
        string name;
        uint256 timestamp;
    }

    mapping(address => Flight) private flights;

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor(address firstAirline) 
    {
        contractOwner = msg.sender;
        addFirstAirline(firstAirline);
    }

    function addFirstAirline(address airlineAddress) private {
        Airline storage airline = airlines[airlineAddress];
        airline.status = AirlineStatus.Registered;
        airline.name = "Airline Admin";
        airlinesRegistered = airlinesRegistered.add(1);
    }
 
    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireAirlineRegistered()
    {
        require(airlines[msg.sender].status == AirlineStatus.Registered, "Caller is not an Airline Registered");
        _;
    }

    modifier requireAirlineNotVoter(address airlineAddress)
    {
        require(airlines[msg.sender].voters[airlineAddress], "Caller already voted");
        _;
    }

    modifier requireMinFoundValue()
    {
        require(msg.value >= 10 ether, "Minimum value to found Airline is 10 ETH");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus(bool mode) external requireContractOwner 
    {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the init queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function initAirline(address airlineAddress, string memory airlineName) external requireIsOperational
    {
        Airline storage airline = airlines[airlineAddress];
        airline.status = AirlineStatus.Init;
        airline.name = airlineName;
    }

    function registerAirline(address airlineAddress) external requireIsOperational
    {
        Airline storage airline = airlines[airlineAddress];
        airline.status = AirlineStatus.Registered;
        airlinesRegistered = airlinesRegistered.add(1);
    }

    function fundAirline(address airlineAddress, uint256 value) external requireIsOperational
    {
        Airline storage airline = airlines[airlineAddress];
        airline.status = AirlineStatus.Funded;
        airline.balance = airline.balance.add(value);
    }

    function registerFlight(bytes32 key, address airline, string memory name) external requireIsOperational
    {
        Flight flight = flights[key];
        flight.airline = airline;
        flight.name = name;
        flight.timestamp = block.timestamp;
        flight.status = FlightStatus.Unknown;
    }

    function setOnTimeFlight(bytes32 key) external requireIsOperational
    {
        Flight flight = flights[key];
        flight.status = FlightStatus.OnTime;
    }

    function setLateFlight(bytes32 key) external requireIsOperational
    {
        Flight flight = flights[key];
        flight.status = FlightStatus.Late;
    }


   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (                             
                            )
                            external
                            payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                )
                                external
                                pure
    {
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                            )
                            external
                            pure
    {
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    receive() external payable 
    {
        fund();
    }


}

