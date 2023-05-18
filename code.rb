using System.Data.SqlClient;

namespace buzzfeed
{
    class Quiz
    {
        public int Id;
        public string Name;
        public List<Question> Questions;
        //public List<Result> Results;
    }

    class Question
    {
        public int Id;
        public string Text;
        public List<Answer> Answers;
    }

    class Answer
    {
        public int Id;
        public string Text;
        public int ResultScore;
    }
    internal class Program
    {
        static void Main(string[] args)
        {
            // database connection
            SqlConnection connection = new SqlConnection(@"Data Source=minecraft.lfgpgh.com;Initial Catalog=Buzzfeed3;Persist Security Info=True;User ID=academy_student;Password=baseball");
            connection.Open();

            //Step 2: Show the user a list of available quizzes they can take (ask for which quiz they want to take)
            string whichQuiz = AskWhichQuiz(connection);

            // Load up the quizzes into the classes for me.

            // loads up one quiz
            Quiz quiz = LoadQuiz(connection, whichQuiz);

            foreach(Question q in quiz.Questions)
            {
                Console.WriteLine(q.Text);
                foreach (Answer a in q.Answers)
                {
                    Console.WriteLine(a.Text);
                }
                Console.WriteLine();
            }
        }

        private static Quiz LoadQuiz(SqlConnection connection, string whichQuiz)
        {
            Quiz quiz = new Quiz();
            SqlCommand command = new SqlCommand($"SELECT * FROM Quizzes WHERE QuizId={whichQuiz}", connection);
            SqlDataReader reader = command.ExecuteReader();
            reader.Read();
            quiz.Name = reader["QuizTitle"].ToString();
            quiz.Id = Convert.ToInt32(reader["QuizId"]);
            reader.Close();

            // load up the questions for that quiz
            quiz.Questions = new List<Question>();
            string sql = "";
            sql += "SELECT * FROM Questions ";
            sql += $"WHERE QuizId = {whichQuiz} ";
            command = new SqlCommand(sql, connection);
            reader = command.ExecuteReader();
            while (reader.Read())
            {
                Question question = new Question();
                question.Text = reader["Title"].ToString();
                question.Id = Convert.ToInt32(reader["QuestionId"]);
                quiz.Questions.Add(question);
            }
            reader.Close();

            // load up the answers for each question
            // loop through the questions and stick the answers in
            foreach (Question question in quiz.Questions)
            {
                question.Answers = new List<Answer>();
                sql = $"SELECT * FROM Answers WHERE QuestionId={question.Id}";
                command = new SqlCommand(sql, connection);
                reader = command.ExecuteReader();
                while (reader.Read())
                {
                    Answer answer = new Answer();
                    answer.Text = reader["AnswerText"].ToString();
                    answer.Id = Convert.ToInt32(reader["AnswerId"]);
                    answer.ResultScore = Convert.ToInt32(reader["ResultScore"]);
                    question.Answers.Add(answer);
                }
                reader.Close();
            }
            return quiz;
        }

        static void OldMain(string[] args)
        {
            // todo:
            // error checking for which quiz

            // database connection
            SqlConnection connection = new SqlConnection(@"Data Source=minecraft.lfgpgh.com;Initial Catalog=Buzzfeed3;Persist Security Info=True;User ID=academy_student;Password=baseball");
            connection.Open();

            //Step 1: Prompt for User name and store in Users Table (get back the Id so we can use it later)
            string userId = SaveUser(connection);

            //Step 2: Show the user a list of available quizzes they can take (ask for which quiz they want to take)
            string whichQuiz = AskWhichQuiz(connection);

            //Step 3: Ask the user all the questions in the questions that match the specific quizId that they chose earlier
            //string sql = $"SELECT * FROM Questions WHERE QuizId={whichQuiz};";
            string sql = "";
            sql += "SELECT * FROM Questions ";
            sql += "JOIN Answers ";
            sql += "ON Questions.QuestionId = Answers.QuestionId ";
            sql += $"WHERE QuizId = {whichQuiz} ";
            sql += "ORDER BY Answers.QuestionId";

            SqlCommand cmd = new SqlCommand(sql, connection);
            SqlDataReader reader = cmd.ExecuteReader();

            Console.WriteLine("\nOK THEN answer these questions:");
            string currentQuestion = "";
            string questionAnswer = "";
            while (reader.Read())
            {
                // if this is a new question, print the question (and update currentQuestion)
                if (reader["Title"].ToString() != currentQuestion)
                {
                    if (currentQuestion != "")
                    {
                        // here's where I want to stop and get an answer - before I print out the next question.
                        Console.Write("What is your answer?: ");
                        questionAnswer = Console.ReadLine();
                        // store that answer in a variable that will hold them all
                        //[[quizid, score, userid, resultid], ]
                    }
                    Console.WriteLine("\n" + reader["Title"]);
                    currentQuestion = reader["Title"].ToString();
                }
                // always print the answer
                Console.WriteLine($"{reader["AnswerId"]}). {reader["AnswerText"]}");
            }
            Console.Write("What is your answer?: ");
            questionAnswer = Console.ReadLine();
            reader.Close();
            // store all the answers in the table for user answers




            //ask them questions 1 by 1 and take answers 1 by 1
            //Get all the QuestionIDs for the Questions in the Quiz selected
            //Print the selected questions/answers out for the user
            //User makes an answer selection from the above and is saved into the UserResultsScore table



            //Step 4: See which column=ResultID in UserResultScores table has the most tallies
            //Step 5: take all the scoring data stored in the UserResultScores Table,
            //and match it to the correct Result Title and correct QuizId in the Results Table
            //Step 6: print out to user Results Title and Results Text (in the Results table)
        }

        private static string AskWhichQuiz(SqlConnection connection)
        {
            string sql = "SELECT * FROM Quizzes;";
            SqlCommand cmd = new SqlCommand(sql, connection);
            SqlDataReader reader = cmd.ExecuteReader();

            Console.WriteLine("\nPlease pick a quiz that you'd like to take!");
            while (reader.Read())
            {
                Console.WriteLine($"{reader["QuizId"]}). {reader["QuizTitle"]}");
            }
            string whichQuiz = Console.ReadLine();
            reader.Close();
            return whichQuiz;
        }

        private static string SaveUser(SqlConnection connection)
        {
            Console.WriteLine("What is your name?");
            string name = Console.ReadLine();

            string sql = "";
            sql += $"INSERT INTO Users (Name) VALUES ('{name}');";
            sql += "SELECT @@IDENTITY AS UserId;";

            SqlCommand cmd = new SqlCommand(sql, connection);
            SqlDataReader reader = cmd.ExecuteReader();
            reader.Read();
            string userId = reader["UserId"].ToString();
            reader.Close();
            return userId;
        }
    }
}
