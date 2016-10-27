using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuickJoin
{
    class Program
    {
        static int Main(string[] args)
        {
            if (args.Length != 4)
            {
                Console.WriteLine("Usage: QuickJoin <col small> <col2 large> <small file> <large file>");
                Console.WriteLine("Join the small file with the large file.");
                Console.WriteLine("Error: wrong number of parameters.");
                return -1;
            }

            var col1 = int.Parse(args[0]) - 1;
            var col2 = int.Parse(args[1]) - 1;
            var fn1 = args[2];
            var fn2 = args[3];

            var fn1Set = new HashSet<string>(File.ReadLines(fn1)
                .Select(x => x.Split('\t')[col1]));
            Console.Error.WriteLine("Fn1 parsed. {0} lines.", fn1Set.Count);

            int count = 0;
            foreach(var line in File.ReadLines(fn2))
            {
                count++;
                if (count % 10000 == 0)
                {
                    Console.Error.WriteLine("{0} lines processed.", count);
                }
                if (fn1Set.Contains(line.Split('\t')[col2]))
                {
                    Console.WriteLine(line);
                }
            }

            return 0;
        }
    }
}
