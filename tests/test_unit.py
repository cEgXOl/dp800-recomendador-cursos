import json
import unittest
from unittest.mock import patch, MagicMock
from rag import generate_answer
from app import recommend

class RagValidationTests(unittest.TestCase):
    def test_no_sources_does_not_generate(self):
        with patch('rag.urllib.request.urlopen') as request:
            answer=generate_answer('moda',[])
            self.assertFalse(answer['generated'])
            self.assertEqual(answer['citations'],[])
            request.assert_not_called()

    def test_unknown_or_inconsistent_citations_are_rejected(self):
        for output in ({'recommendations':[{'courseId':999,'reason':'SQL'}]},
                       {'recommendations':[{'courseId':1,'reason':'Curso [999]'}]},
                       {'recommendations':[{'courseId':1,'reason':'Dura 180 minutos'}]},
                       {'recommendations':[]}):
            with self.subTest(output=output):
                response=MagicMock()
                response.read.return_value=json.dumps({'done':True,'message':{'content':json.dumps(output)}}).encode()
                with patch('rag.urllib.request.urlopen') as request:
                    request.return_value.__enter__.return_value=response
                    with self.assertRaises(RuntimeError):
                        generate_answer('consulta',[{'id':1,'title':'SQL'}])

    def test_missing_price_is_not_invented(self):
        with patch('rag.urllib.request.urlopen') as request:
            answer=generate_answer('Qué precio tienen los cursos?', [{'id':1,'title':'SQL'}])
            self.assertFalse(answer['generated'])
            self.assertIn('precios',answer['answer'])
            request.assert_not_called()

    def test_invalid_input_does_not_call_embedding(self):
        for payload in ({'query':''},{'query':'sql','level':'Other'},
                        {'query':'sql','maxDuration':-1},{'query':'sql','categoryId':-2}):
            with patch('app.embed_query') as embed:
                with self.assertRaises(ValueError): recommend(payload)
                embed.assert_not_called()

if __name__=='__main__': unittest.main()
