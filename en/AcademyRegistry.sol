pragma solidity ^0.8.1;

// https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AcademyRegistry is ERC721, Ownable{

  // Library Counters will be responsable for enumerating the identifiers of the counters.
  using Counters for Counters.Counter;
  // Storage and returns by calls the total amount of subjects.
  Counters.Counter public totalSubjects;

  // The key: ID(uint256), receives the value: name of subject(string).
  mapping(uint256 => string) private idToSubject;
  // The key: Students(address), increment the value: ID(uint256) of subject. 
  // The key: Students(address), increment the value: ID(uint256) of subject.
  mapping(address => uint256[]) private studentToIds;
  // The key: Bytes(bytes4), receive the value: '0' or '1'(uint8).
  mapping(bytes4 => uint8) private registry;

  // Constructor
  constructor() ERC721("Web3Dev", "W3D") {
  }

  /// @dev
  /// Function registers the student on a subject and return the receipt that represents its enrollment.
  /// Returns bytes4 - Subject receipt.
  /// @param _student(address) - student addres.
  /// @param _id(uint256) - Id of the subject.
  function addStudentToSubject(address _student, uint256 _id) public onlyOwner returns(bytes4){

    // Encode by concatenation of strings.
    // Keccak to hash the previously combined strings, results in bytes32.
    // Bytes4 to convert the bytes32 into bytes4, there is plenty for this usecase. Bytes4 = 0xFF00FF00FF00FF00 {16 chars}
    bytes4 hashes = bytes4(keccak256(abi.encodePacked(_student, _id)));
    // Use the hash as a key, it receives the given value, and checks if the student is already enrolled in the subject. 
    // it must be different from one { 0 = Enters, 1 = Rejects}.
    require(registry[hashes] != 1,"Student already registered in this subject.");
    // Register 'true' (1) to the specified hash
    registro[hashes] = 1;

    // Verify if the subject exists by checking the possible lenght of the given subject id.
    require(bytes(idToSubject[_id]).length == 0,"Subject doesn't exist.");

    // The key of the map is the student address and the value is the subject id.
    studentToIds[_student].push(_id);

    // It return the hash of the generated receipt.
    return hashes;
  }

  function getSubjectName(uint256 _id) public view returns (string memory) {

  }

  /// @dev
  /// Function to add another subject.
  /// @param _subject(string memory) - Name of the subject.
  function addSubject(string memory _subject) public onlyOwner {
    totalSubjects.increment();
    uint256 newSubjectId = totalSubjects.current();
    idToSubject[newSubjectId] = _subject;
  }

  /// @dev
  /// Function to return all the subject from a given student.
  /// @param _student(address) - Student address.
  /// Returns uint256[] - Array containing all the student's subject.
  function getAllSubjectsOfStudent(address _student) external view returns(uint256[] memory) {
    return studentToIds[_student];
  }

}
