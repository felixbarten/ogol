module Test::Test

import IO;
import List;

list[str] text = ["andra", "moi", "ennepe", "Mousa", "polutropon"];
public int count(list[str] text){
  n = 0;
  for(s <- text)
    if(/a+/ := s)
      n +=1;
  return n;
}

public int testOperator(){
	n = 0;
	string = "abcdefg";
	if(/[a]$/ := string) 
		n = 1;
	
	println("res is");
	res = ((/[a]/ := string) ? 1 : 2);
	println(res);

	return n;
}
public list[str] reverseList(list[str] words) {
	return for(int i <- [size(words).. 0]) append words[i-1];
}

public bool isPalindrome(list[str] words){
  return words == reverseList(words);
}

public bool isPalindrome2(list[str] words){
  //return for(i <- [size(words)..0])append words[ i - 1 ]);
  return for(int i <- [size(words).. 0]) {append words[i-1];} == words;
  // niet andersom words == ........
}
