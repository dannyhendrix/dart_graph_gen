import "package:test/test.dart";
import "../tokenizer.dart";

void main()
{
  test("IdReader ab", () {
    var reader = new IdTokenReader();
    var resultStart = reader.start("a");
    expect(resultStart, equals(TokenReaderResult.Valid));
    var resultNext = reader.next("b");
    expect(resultNext, equals(TokenReaderResult.Valid));
    expect(reader.token.token, equals("ab"));
  });
  test("IdReader a7", () {
    var reader = new IdTokenReader();
    var resultStart = reader.start("a");
    expect(resultStart, equals(TokenReaderResult.Valid));
    var resultNext = reader.next("7");
    expect(resultNext, equals(TokenReaderResult.Valid));
    expect(reader.token.token, equals("a7"));
  });
  test("IdReader fail", () {
    var reader = new IdTokenReader();
    var resultStart = reader.start("8");
    expect(resultStart, equals(TokenReaderResult.Invalid));
    expect(reader.token, equals(null));
  });
}