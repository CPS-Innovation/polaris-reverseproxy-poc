import nginx from "./nginx.js";
import { expect, jest, test } from "@jest/globals";

process.env.API_ENDPOINT = "test.example.com";

test("cookie, referer, q all defined", () => {
  const r = {
    args: {
      q: "[1,2,3]",
    },
    headersIn: {
      Referer: "bar=a",
      Cookie: 'foo:&?"[1,2,3]',
    },
    return: jest.fn(),
  };
  nginx.fetch(r);
  expect(r.return).toHaveBeenCalledWith(
    302,
    "https://test.example.com/init?cookie=foo%3A%26%3F%22%5B1%2C2%2C3%5D&referer=bar%3Da&q=[1,2,3]"
  );
});

test("cookie, referer, q not defined", () => {
  const r = {
    args: {},
    headersIn: {},
    return: jest.fn(),
  };
  nginx.fetch(r);
  expect(r.return).toHaveBeenCalledWith(
    302,
    "https://test.example.com/init?cookie=&referer=&q="
  );
});
