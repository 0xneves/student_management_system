pragma solidity ^0.8.1;

// https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RegistroDaAcademia is ERC721, Ownable{

  // Biblioteca Counters será responsável por enumerar os identificadores dos cursos.
  using Counters for Counters.Counter;
  // Armazena e retorna publicamente por chamadas externas o total de cursos.
  Counters.Counter public totalDeCursos;

  // A chave: ID(uint256), recebe o valor: nome da matéria(string).
  mapping(uint256 => string) private idParaNome;
  // A chave: Alunos(address), acrescentar o valor: ID(uint256) da matéria.
  mapping(address => uint256[]) private alunoParaIds;
  // A chave: Bytes(bytes4), recebe somente valores: '0' ou '1'(uint8).
  mapping(bytes4 => uint8) private registro;

  // Construtor
  constructor() ERC721("Web3Dev", "W3D") {
  }

  /// @dev
  /// Função para registrar um Aluno e retornar o comprovante da matrícula
  /// Returns bytes4 - Comprovante da matrícula.
  /// @param _aluno(address) - Endereço do Aluno.
  /// @param _id(uint256) - ID da matéria.
  function adicionarAluno(address _aluno, uint256 _id) public onlyOwner returns(bytes4){

    // Encode para concatenação de strings
    // Keccak para fazer o hash da string e passar o valor para bytes
    // Bytes4 para delimitarmos o tamanho máximo em bytes para alocação de memória Bytes4 = 0xFF00FF00FF00FF00 {16 chars}
    bytes4 hashes = bytes4(keccak256(abi.encodePacked(_aluno, _id)));
    // Usa o hash criado como chave, recebe o valor referente, verifica se o Aluno já está matriculado na matéria. 
    // Precisa ser diferente de 1 { 0 = Entra, 1 = Rejeita.}
    require(registro[hashes] != 1,"Aluno ja matriculado na materia");
    // Registra 'true' (1) para o hash específico
    registro[hashes] = 1;

    // Verifica se o curso é existente com base no tamanho da string retornada no id especificado
    require(bytes(idParaNome[_id]).length == 0,"Curso nao existente");

    // A chave do mapa é o endereço(_aluno) do aluno e o valor(id) é o ID da matéria. Acrescentamos com push.
    alunoParaIds[_aluno].push(_id);

    // Retorna o hash que comprova a matrícula.
    return hashes;
  }

  /// @dev
  /// Função para adicionar uma matéria
  /// @param _curso(string memory) - Nome da matéria.
  function adicionarCurso(string memory _curso) public onlyOwner {
    totalDeCursos.increment();
    uint256 novoIdParaCurso = totalDeCursos.current();
    idParaNome[novoIdParaCurso] = _curso;
  }

  /// @dev
  /// Função para retornar todos os cursos de um determinado aluno
  /// @param _aluno(address) - Endereço do aluno.
  /// Returns uint256[] - Array contendo todos os ids de curso.
  function pegarCursosDoEstudante(address _aluno) external view returns(uint256[] memory) {
    return alunoParaIds[_aluno];
  }

}
