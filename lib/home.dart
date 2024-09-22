import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const PuzzleGame());
}

class PuzzleGame extends StatelessWidget {
  const PuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hadeel | Puzzle Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/puz.json', width: 150, height: 150), 
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PuzzleScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text(
                "إبدأ اللعبة",
                style: TextStyle(color: Colors.white, fontSize: 25), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  int secondsRemaining = 300; 
  bool isGameOver = false;
  Timer? timer;
  List<Image> puzzlePieces = [];
  List<int> shuffledIndices = [];
  int emptyIndex = 8; 
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    generatePuzzle();
    startGame();
  }

  void generatePuzzle() {
    puzzlePieces = List.generate(8, (index) {
      return Image.asset('assets/game$index.png'); 
    });

    shuffledIndices = List.generate(9, (index) => index);

    shuffledIndices.shuffle();

    emptyIndex = shuffledIndices.indexOf(8);
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      secondsRemaining = 300; 
      isGameOver = false;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          isGameOver = true;
          timer.cancel();
          showGameOverDialog();
        }
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "😞مااااش حاول مرة ثانية",
            style: TextStyle(color: Colors.white, fontSize: 35),
          ),
          backgroundColor: Colors.green,
          content: const Text(
            "🫡معوض خير يا بطل راحت عليك،حاول مرة ثانية يا أقوى سعودي",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
              child: const Text("تم", style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ],
        );
      },
    );
  }

  void restartGame() {
    setState(() {
      shuffledIndices.shuffle();
      emptyIndex = shuffledIndices.indexOf(8); 
      isPlaying = false;
      startGame(); 
    });
  }

  bool canSwap(int index) {
    int row = index ~/ 3;
    int col = index % 3;
    int emptyRow = emptyIndex ~/ 3;
    int emptyCol = emptyIndex % 3;

    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
           (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  void onTileTapped(int index) {
    if (canSwap(index)) {
      setState(() {
        shuffledIndices[emptyIndex] = shuffledIndices[index];
        shuffledIndices[index] = 8; 
        emptyIndex = index;

        if (shuffledIndices.sublist(0, 8).every((element) => shuffledIndices[element] == element)) {
          showWinDialog(); 
        }
      });
    }
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("🥳كفووووو", style: TextStyle(color: Colors.white, fontSize: 35),),
            backgroundColor: Colors.green,
          content: const Text("مبروك تستاهلها سواء جبتها بتعبك ولا من ورا التريلات🤓",style: TextStyle(color: Colors.white, fontSize: 20)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
              child: const Text("تم", style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double tileSize = screenWidth / 4.5; 

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "اسبق الوقت لا يسبقك: $secondsRemaining",
              style: const TextStyle(color: Color.fromARGB(255, 3, 93, 6), fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10), 
                itemCount: 9, 
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  if (shuffledIndices[index] == 8) {
                    return Container(
                      width: tileSize,
                      height: tileSize,
                      color: Colors.grey[300], 
                    );
                  } else {
                    return GestureDetector(
                      onTap: () => onTileTapped(index),
                      child: Container(
                        width: tileSize,
                        height: tileSize,
                        child: puzzlePieces[shuffledIndices[index]],
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  shuffledIndices = List.generate(9, (index) => index); 
                  showWinDialog(); 
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                "رتبها",
                style: TextStyle(color: Color.fromARGB(255, 3, 93, 6), fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
