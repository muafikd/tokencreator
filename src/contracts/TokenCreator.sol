// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


interface IERC20{
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);

    function transfer(address to, uint256 amount) external returns(bool);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
}

contract MERC20 is IERC20{
    //Values of Token
    uint256 _totalSupply; //All tokens 
    string _name; //Name
    string _symbol; //Short name
    uint8 _decimals; //Decimals. Number of zeros of token. E.g: 1 ruble = 100 kopeika. It means 1 ruble has 2 decimals.
    address _owner; //Owner account

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    //mapping(from => mapping(spender => amount))
    //from - address from where tokens are allowed to spend
    //spender - address is who is allowed to spend tokens from address 'from'
    //amount - is amount of tokens which are allowed to spend to address 'spender'

    constructor(string memory name_, string memory symbol_){
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _owner = msg.sender;
    }

    //View functions
    function name() public view returns(string memory){
        return _name;
    }
    function symbol() public view returns(string memory){
        return _symbol;
    }
    function decimals() public view returns(uint8){
        return _decimals;
    }
    function totalSupply() public view returns(uint256){
        return _totalSupply;
    }
    function balanceOf(address account) public view returns(uint256){
        return balances[account];
    }
    function allowance(address owner, address spender) public view returns(uint256){
        return allowed[owner][spender];
    }

    //Functions that interacts with tokens
    function transfer(address to, uint256 amount) public returns(bool){
        require(balances[msg.sender] >= amount, "ERC20: Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns(bool){
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns(bool){
        require(balances[from] >= amount, "ERC20: not enough tokens");
        require(allowed[from][msg.sender] >= amount, "ERC20: no permission to spend");
        balances[from] -= amount;
        balances[to] +=amount;
        allowed[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        emit Approval(from, msg.sender, amount);
        return true;
    }

    function mint(address to, uint256 amount) public returns(bool){
        require(msg.sender == _owner, "ERC20: not owner call");
        balances[to] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), to, amount);
        return true;
    }

    function burn(uint256 amount) public returns(bool){
        require(balances[msg.sender] >= amount, "ERC20: invalid amount");
        _totalSupply -= amount;
        balances[address(0)] += amount;
        balances[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addValue) public returns(bool){
        allowed[msg.sender][spender] += addValue;
        emit Approval(msg.sender, spender, addValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subValue) public returns(bool){
        allowed[msg.sender][spender] -= subValue;
        emit Approval(msg.sender, spender, subValue);
        return true;
    }
}



interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


contract ERC7210 is IERC721, IERC721Metadata, ERC165{
    //Переменные контракта
    uint256 tokenId;
    string _name;
    string _symbol;
    string baseUri;
    address owner;
    //Мэппинги для хранения информации о балансах, адресов токенов
    mapping(uint256 => address) owners;
    mapping(address => uint256) balances;
    //Мэппинги для хранения информации о разрешениях 
    mapping(uint256 => address) tokenApprovals;
    mapping(address => mapping(address => bool)) operatorApprovals;
    //Событие для того чтобы ловить какие-либо ошибки и т.д.
    event Fallback(address caller, uint256 time);

    //Конструктор
    constructor(string memory name_,  string memory symbol_){
        owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
    }
    
    fallback() external {
        emit Fallback(msg.sender, block.timestamp);
    }

    // функция эмиссии токенов
    function mint(address to) public returns (uint256) {
        require(msg.sender == owner, "ERC721: You are not owner");
        tokenId++;
        owners[tokenId] = to;   
        balances[to]++;
        emit Transfer(address(0), to, tokenId);
        return tokenId; 
    }

    // функция для установки прав оператора для одного конкретного токена
    function approve(address _spender, uint256 _tokenId) public {
        address _owner = owners[_tokenId];
        require(_owner != _spender, "ERC721: approval to current owner");
        require(
            _owner == msg.sender || 
            tokenApprovals[_tokenId] == msg.sender || 
            operatorApprovals[_owner][msg.sender], 
            "ERC721: approve caller is not owner or approved for all"
            );
        tokenApprovals[_tokenId] = _spender;
        emit Approval(msg.sender, _spender, _tokenId);
    }

    // функция для установки прав оператора на все токены
    function setApprovalForAll(address _operator, bool _approved) public {
        require(msg.sender != _operator, "ERC721: approve to caller");
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // функция трансфера без проверки адреса _to
    function transferFrom(address _from, address _to, uint256 _tokenId) external{
        _transfer(_from, _to, _tokenId);
    }

    // функция трансфера с проверкой, что адрес _to поддерживает интерфейс IERC721Receiver
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, ""), "ERC721: transfer to non ERC721Receiver implementer");
    }

    // функция трансфера с проверкой, что адрес _to поддерживает интерфейс IERC721Receiver
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) external{
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        address _owner = owners[_tokenId];
        require(_owner == _from, "ERC721: from is not the owner of the tokenId");
        require(
            _owner == msg.sender || 
            tokenApprovals[_tokenId] == msg.sender || 
            operatorApprovals[_owner][msg.sender], 
            "ERC721: transfer caller is not owner or approved" 
            );
        tokenApprovals[_tokenId] = address(0);
        balances[_from] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

   // функция проверки поддерживаемых интерфейсов
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // возвращает название токена
    function name() public view returns (string memory){
        return _name;
    }

    // возвращает символа токена
    function symbol() public view returns (string memory){
        return _symbol;
    }

    // возращает id Токена
    function getTokenId() public view returns (uint256) {
        return tokenId;
    }

    // возвращает URI токена по его id
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        require(owners[_tokenId] != address(0), "ERC721: URI query for nonexistent token");
        return string(abi.encodePacked(baseUri, toString(_tokenId)));
    }

    // возвращает баланса аккаунта по его адресу
    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    // возвращает адрес владельца токена по его id
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return owners[_tokenId];
    }

    // проверка прав оператора на конкретный токен
    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }
    // проверка прав оператора на конкретный токен


    // проверка прав оператора на все токены
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

	// функция проверки наличия необходимого интерфейса на целевом аккаунте
    function _checkOnERC721Received(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) private returns (bool) {
        // если на целевом аккаунт длина кода больше 0 - то это контракт
        if (_to.code.length > 0) {
            // если контракт - пробуем вызвать на целевом контракте функцию onERC721Received
            try IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, data) returns (bytes4 response) {
                // если функция вернула значение, равное селектору функции onERC721Received - то всё ок
                return response == IERC721Receiver.onERC721Received.selector;
            // если на целевом контракте не удалось вызвать функцию onERC721Received - возвращаем false
            } catch {
                return false;
            }
        // если не контракт - возвращаем сразу true
        } else {
            return true;
        }
    }

    // Функция для перевода числа в строку
    function toString(uint256 value) internal pure returns(string memory) {
        uint256 temp = value;
        uint256 digits;
        do {
            digits++;
            temp /= 10;
        } while (temp != 0);
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

}

contract TokenFactory {
    mapping(address => address) public tokenAddresses;


    event TokenCreated(address);
    function createERC20Token(string memory name, string memory symbol, uint256 initialSupply) public returns(address) {
        ERC20Token newToken = new ERC20Token(name, symbol, initialSupply, msg.sender);
        tokenAddresses[msg.sender] = address(newToken);
        emit TokenCreated(address(newToken));
        return address(newToken);
    }

    function createERC721Token(string memory name, string memory symbol) public returns(address) {
        ERC721Token newToken = new ERC721Token(name, symbol, msg.sender);
        tokenAddresses[msg.sender] = address(newToken);
        emit TokenCreated(address(newToken));
        return address(newToken);
    }
}

contract ERC20Token is MERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply, address tokenOwner) MERC20(name, symbol) {
        mint(tokenOwner, initialSupply);
    }
}

contract ERC721Token is ERC7210 {
    constructor(string memory name, string memory symbol, address owner) ERC7210(name, symbol) {
        mint(owner);
    }
}
