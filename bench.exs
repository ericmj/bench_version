string = "~> 1.2.3 and ~> 1.0"
requirement = Version.parse_requirement!(string)
compiled_requirement = Version.compile_requirement(requirement)
lexed_requirement = BenchVersion.lexer(string)

versions =
  for major <- 1..10,
      minor <- 1..10,
      patch <- 1..10,
      pre <- [[], ["dev"]],
      do: %Version{major: major, minor: minor, patch: patch, pre: pre, build: nil}

Benchee.run(
  %{
    "requirement" => fn -> Enum.map(versions, &Version.match?(&1, requirement)) end,
    "compiled requirement" => fn -> Enum.map(versions, &Version.match?(&1, compiled_requirement)) end,
    "matching requirement" => fn -> Enum.map(versions, &BenchVersion.lexed_match?(&1, lexed_requirement)) end
  },
  time: 10,
  memory_time: 2
)
