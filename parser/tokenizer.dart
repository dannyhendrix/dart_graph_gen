library tokenizer;

import 'dart:async';
import 'dart:io';

abstract class Token<T>
{
  T token;
  int position;

  String toString()
  {
    return "${runtimeType.toString()}($position): ${token.toString()}";
  }
}

class StrToken extends Token<String>
{
  int position;
  StrToken(this.position, int str)
  {
    token = new String.fromCharCode(str);
  }
  void append(int str)
  {
    token += new String.fromCharCode(str);
  }
}
class IdToken extends Token<String>
{
  int position;
  IdToken(this.position, int str)
  {
    token = new String.fromCharCode(str);
  }
  void append(int str)
  {
    token += new String.fromCharCode(str);
  }
}
class IntToken extends Token<int>
{
  int position;
  IntToken(this.position, int val)
  {
    token = val;
  }
  void append(int val)
  {
    token = (token*10)+val-48;
  }
}
class OpToken extends Token<String>
{
  int position;
  OpToken(this.position, int str)
  {
    token = new String.fromCharCode(str);
  }
  void append(int str)
  {
    token += new String.fromCharCode(str);
  }
}

enum TokenReaderResult {Valid, Invalid, LineComment, MultilineComment}

abstract class TokenReader<T extends Token>
{
  T token;
  TokenReaderResult start(int position, int str);
  TokenReaderResult next(int str);
}

class SpaceTokenReader extends TokenReader<Token>
{
  TokenReaderResult start(int position, int str) => str == 32 ? TokenReaderResult.Valid : TokenReaderResult.Invalid;
  TokenReaderResult next(int str) => str == 32 ? TokenReaderResult.Valid : TokenReaderResult.Invalid;
}
class NewlineTokenReader extends TokenReader<Token>
{
  TokenReaderResult start(int position, int str) => str == 13 || str == 10 ? TokenReaderResult.Valid : TokenReaderResult.Invalid;
  TokenReaderResult next(int str) => str == 13 || str == 10 ? TokenReaderResult.Valid : TokenReaderResult.Invalid;
}
class IdTokenReader extends TokenReader<IdToken>
{
  TokenReaderResult start(int position, int str)
  {
    if(str < 65 || str > 122 || (str > 90 && str < 97))
      return TokenReaderResult.Invalid;
    token = new IdToken(position, str);
    return TokenReaderResult.Valid;
  }
  TokenReaderResult next(int str)
  {
    if(str < 48 || str > 122 || (str > 57 && str < 65) || (str > 90 && str < 97))
      return TokenReaderResult.Invalid;
    token.append(str);
    return TokenReaderResult.Valid;
  }
}
class StringTokenReader extends TokenReader<StrToken>
{
  int opened = -1;
  int lastChar = -1;
  TokenReaderResult start(int position, int str)
  {
    if(str != 34 && str != 39)
      return TokenReaderResult.Invalid;
    token = new StrToken(position, str);
    opened = str;
    return TokenReaderResult.Valid;
  }
  TokenReaderResult next(int str)
  {
    if(opened == -1)
      return TokenReaderResult.Invalid;
    if(str == opened && lastChar != 92)// 92 => \ (escape)
      opened = -1;
    token.append(str);
    lastChar = str;
    return TokenReaderResult.Valid;
  }
}
class MultilineCommentTokenReader extends TokenReader<Token>
{
  int lastChar = -1;
  bool opened = false;
  TokenReaderResult start(int position, int str)
  {
    opened = true;
    return TokenReaderResult.Valid;
  }
  TokenReaderResult next(int str)
  {
    if(!opened)
      return TokenReaderResult.Invalid;
    if(str == 47 && lastChar == 42)// / *
      opened = false;
    lastChar = str;
    return TokenReaderResult.Valid;
  }
}
class LineCommentTokenReader extends TokenReader<Token>
{
  int lastChar = -1;
  bool opened = false;
  TokenReaderResult start(int position, int str)
  {
    opened = true;
    return TokenReaderResult.Valid;
  }
  TokenReaderResult next(int str)
  {
    if(!opened)
      return TokenReaderResult.Invalid;
    if(str == 10)
      opened = false;
    return TokenReaderResult.Valid;
  }
}
class IntTokenReader extends TokenReader<IntToken>
{
  TokenReaderResult start(int position, int str)
  {
    if(str < 48 || str > 57)
      return TokenReaderResult.Invalid;
    token = new IntToken(position, str);
    return TokenReaderResult.Valid;
  }
  TokenReaderResult next(int str)
  {
    if(str < 48 || str > 57)
      return TokenReaderResult.Invalid;
    token.append(str);
    return TokenReaderResult.Valid;
  }
}
class OpTokenReader extends TokenReader<OpToken>
{
  int firstChar = -1;
  bool isOpt(int index)
  {
    if(index == 33)
      return true;
    if(index < 35)
      return false;
    if(index <= 38)
      return true;
    if(index < 40)
      return false;
    if(index <= 47)
      return true;
    if(index < 58)
      return false;
    if(index <= 64)
      return true;
    if(index < 91)
      return false;
    if(index <= 95)
      return true;
    if(index < 123)
      return false;
    if(index <= 125)
      return true;
    return false;
  }

  TokenReaderResult start(int position, int str)
  {
    if(!isOpt(str))
      return TokenReaderResult.Invalid;
    token = new OpToken(position, str);
    firstChar = str;
    return TokenReaderResult.Valid;
  }
  TokenReaderResult next(int str)
  {
    if(str == 42 && firstChar == 47)// * /
      return TokenReaderResult.MultilineComment;
    if(str == 47 && firstChar == 47)// / /
      return TokenReaderResult.LineComment;
    new String.fromCharCode(str);
    return TokenReaderResult.Invalid;
  }
}

enum TokenizerState {InToken, TokenStart}

class Tokenizer
{
  Tokenizer(){}

  List<Token> tokenize(String input)
  {
    TokenizerState state = TokenizerState.TokenStart;
    TokenReader currentReader = null;
    TokenReader lineCommentReader = new LineCommentTokenReader();
    TokenReader multilineCommentReader = new MultilineCommentTokenReader();
    final List<TokenReader> tokenReaders = [new NewlineTokenReader(), new SpaceTokenReader(), new IdTokenReader(), new IntTokenReader(), new StringTokenReader(), new OpTokenReader()];
    List<Token> tokens = [];
    List<int> spl = input.codeUnits;
    int position = -1;

    for(int char in spl)
    {
      position++;
      if(state == TokenizerState.InToken)
      {
        TokenReaderResult result = currentReader.next(char);
        if(result == TokenReaderResult.Valid)
          continue;
        else if(result == TokenReaderResult.LineComment)
        {
          print("line comment");
          Token token = currentReader.token;
          currentReader.token = null;
          currentReader = lineCommentReader;
          currentReader.start(position-2, -1);
          continue;
        }
        else if(result == TokenReaderResult.MultilineComment)
        {
          print("multiline comment");
          Token token = currentReader.token;
          currentReader.token = null;
          currentReader = multilineCommentReader;
          currentReader.start(position-2, -1);
          continue;
        }
        if(currentReader.token != null)
          tokens.add(currentReader.token);
        currentReader.token = null;
        currentReader = null;
        state = TokenizerState.TokenStart;
      }
      bool success = false;
      // beginning of new token
      for(TokenReader reader in tokenReaders)
      {
        TokenReaderResult result = reader.start(position, char);
        if(result == TokenReaderResult.Invalid)
          continue;
        currentReader = reader;
        state = TokenizerState.InToken;
        success = true;
        break;
      }
      if(!success)
        throw new Exception("Unable to tokenize ${char} \"${new String.fromCharCode(char)}\"");
    }

    if(currentReader.token != null)
      tokens.add(currentReader.token);
    return tokens;
    //comment //.*
    //multiline /* /n* */
    //id: ([a-zA-Z]+[a-zA-Z0-9])
    //str: ".*" '.*'
    //int: [0-9]+
    //token: ./?<>[]{}()+=*-,%$#
  }
}