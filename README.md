# Estudos looker
Esse projeto conta com dois arquivos de viewer: **athletes** (com informações sobre cada atleta) e **medals** (onde mostra as medalhes que cada atleta ganhou)

Além disso, dentro do arquivo model, há a junção do arquivo **athletes** com o arquivo **medals** através desse código:
```sql
explore: athletes {
  join: medals {
    type: inner
    sql_on: ${athletes.id} = ${medals.id_athlete} ;;
    relationship: one_to_many
  }
}
```
onde:
- `explore: athletes {}`: é uma definição que cria uma exploração (tipo um ponto de partida) para os usuários analisarem os dados chamada athletes (mesmo nome da view, isso significa que todos os dados presente no arquivo **athletes** irá aparecer no explorer **athletes**)
- `join: medals {}`: especifica uma junção com outra tabela ou visualização, onde nesse caso, vamos juntar a tabela **athletes** com a tabela **models**
- `type: inner`: especifica o tipo de junção usado, onde nesse caso, é uma junção interna (inner join), que retorna apenas os registros que têm correspondências nas duas tabelas (usar o `inner` ou invés do `left_outer` vai ser útil para evitar problemas futuros)
- `sql_on: ${athletes.id} = ${medals.id_athlete} ;;`: esta linha define a condição para a junção, onde serão retornados os campo quando o id da tabela **athletes** for igual ao campo **id_athlete** da tabela medals.
- `relationship: one_to_many`: especifica a natureza da relação entre as duas tabelas, indicando que um registro na tabela athletes pode corresponder a muitos registros na tabela medals.

<details>
  <summary>Componentes LookML</summary>

### Mudanças iniciais

**medals.view**

1. Dentro do arquivo **medals.view**, foi criado um componente `set` para realizar um drill_fields dentro da medida count, como no código abaixo:
    ```sql
    measure: count {
        type: count
        drill_fields: [show_details*]
    }
    set: show_details {
        fields: [
        athlete_name,
        country,
        medal_type,
        discipline,
        athletes.height,
        athletes.age
        ]
    }
    ```
    a. Isso permite especifica um conjunto de campos para detalhamento. Quando um usuário clicar para detalhar a medida count na interface do Looker, ele verá os campos definidos no conjunto show_details.

2. Dentro do arquivo **medals.view**, foi criando dois componentes: uma dimensão escondida do tipo `yesno` que retorna como verdadeiro (Yes) quandos os países forem igual ao "United States of America"; e uma medida do tipo `count` que conta as medalhas ganhas por atletas dos Estados Unidos aplicando um filtro para considerar apenas registros onde o país é "United States of America". E por fim permite detalhamento para ver mais informações sobre os atletas e suas medalhas.
    ```sql
    dimension: medal_usa_yesno{
        type: yesno
        hidden: yes
        sql: ${country} = "United States of America" ;;
    }

    measure: total_usa_medal {
        type: count
        label: "United States medals"
        --sql: ${medal_type} ;; o tipo `count` nao usa `sql`
        filters: [medal_usa_yesno: "Yes"]
        drill_fields: [athlete_name,country,medal_type,discipline]
    }
    ```
3. Dentro do arquivo **medals.view**, há a medida `count` para contar a quantidade de medalhas adquiridas, porém, houve atleta que ganhou mais de uma medalha. Para conseguirmos definir a quantidade de atletas que venceram e ganharam medalhas, vamos escrever o seguinte bloco de código:
    ```sql
    measure: count_winners {
        type: count_distinct
        sql: ${id_athlete} ;;
    }
    ```
4. [DELETADO]Dentro do arquivo **medals**, tinha sido criado uma medida que mostra a diferença entre o total de atletas e o total de atletas que ganharam medalhas. Pórem, como o tipo de junção no arquivo **model** está definido como `inner`, criar essa medida dentro do arquivo medels não irá funcionar como o esperado, pois o valor retornado será 0, tendo em vista que a quantidade de atletas totais será igual a quantidade de atletas que ganharam as medalhas, para esse bloco de código funcionar, é necessário definir o tipo da junção como `left_outer`. Porém, como essa medida não é tão relevante, foi deletada e o tipo de junção no arquivo **model** continua como `inner` entre os arquivos **athletes.view** e **medals.view**
    ```sql
    measure: athletes_that_win {
        type: number
        sql:COUNT(DISTINCT athletes.id) - COUNT(DISTINCT id_athlete );;
    }
    ```
5. Dentro do arquivo **medals**, foi criado um componente que conta a quantidade de medalhas que cada país ganhou, e foi implantado em uma medida diferente para que o drill_fields fosse diferente. Nesse caso, vamos poder detalhar a quantidade ganha de cada tipo de medalha por país
    ```sql
    measure: count_country_frequency {
        type: number
        sql: COUNT(${country}) ;;
        drill_fields: [medal_type, count]
    }
    ```

**athletes.view**

1. Dentro do arquivo **athletes.view**, foi criado um `set` semelhante ao criado no arquivo **medals**, só que nesse caso, irá realizar um drill_fields em todos os atletas, e não somente ao atletas que ganharam uma medalha.
    ```sql
    measure: count {
        type: count
        drill_fields: [show_details*]
    }

    set: show_details {
        fields: [
        name,
        country,
        medals.medal_type,
        discipline,
        athletes.height,
        athletes.age
        ]
    }
    ```

2. Dentro do arquivo **athletes.view**, foi criado uma dimensão do tipo `tier` que serve para categorizar algo. Nesse caso, foi usado para categorizar as idades de todos os participantes
    ```sql
    dimension: age_tier {
        type: tier
        tiers: [18, 25, 35, 45, 55, 65] --Define os limites dos intervalos (tiers)
        style: integer
        sql: ${age} ;;
    }
    ```

3. Dentro do arquivo **athletes.view**, foi criado uma dimensão do tipo number, que retorna a idade dos participantes (no código, é usado a data atual para fazer a diferença de idade, e não a data de quando os jogos foram realizados - 2021). Apesar de já ter uma coluna no banco de dados que mostra a idade dos jogadores, esse componente foi utilizado para praticar o trecho `DATE_DIFF(CURRENT_DATE, ${birth_date}, YEAR)`
    ```sql
    dimension: age_diff {
        type: number
        sql: DATE_DIFF(CURRENT_DATE, ${birth_date},YEAR) ;;
    }
    ```

</details>

<details>
  <summary>Dashboard criado</summary>

### Primeiro Look
O primeiro look criado é um look que mostra a diferença do total de medalhas ganhas entre homens e mulheres com base no tipo da medalha. Esse look foi criado da seguinte forma:
- Primeiro, selecionei a dimensão **Medal Type** na viwer **Medals**
- Depois, selecionei a dimensão **Gender** como um _pivot_ na viwer **Athletes**
- Por fim, selecionei a medida **Count** da viwer **Medals**

### Segundo Look
O segundo look criado é um look que mostra a quantidade de atletas totais que competiram com base no intervalo de idade deles. Foi utilizado um gráfico de área nesse look. Esse look foi criado da seguinte forma
- Primeiro, selecionei a dimensão **Age tier** na viwer **Athletes**
- Por fim, selecionei a medida **Count** da viwer **Athletes**

### Terceiro Look
O terceiro look criado é um gráfico que exibe a quantidade de medalhas ganhas por cada atleta. Este gráfico de linha mostra a diferença de idade entre os atletas e os tipos de medalhas que eles ganharam. Esse look foi criado da seguinte forma:
- Primeiro, selecionei a dimensão **Age** na viwer **Athletes**
- Depois, selecionei a dimensão **Medal Type** como um _pivot_ na viwer **Medals**
- Por fim, selecionei a medida **Count** da viwer **Medals**

### Quarto Look
O quarto look criado é um gráfico de valor único que mostra a quantidade de medalhas conquistadas na olimpíada. Esse gráfico foi feito para mostrar que, se o tipo de junção no arquivo **model** estivesse como `left_outer`, agora, quando eu clicasse no valor do gráfico para o detalhamento através do `drill_fields`, haveria dados nulos. Porém, com o tipo de junção `inner`, não há dados nulos

### Quinto Look
O quinto look é do tipo google Maps, e mostra a quantidade de medalhas que cada país ganhou, separados pelos tipos de medalha. Esse look foi criado da seguinte forma:
- Primeiro, selecionei a dimensão **Country** na viwer **Medals**
- Por fim, selecionei a medida **Count Country Frequency** na viwer **Medals**

### Sexto Look
O sexto look é do tipo Pizza (pie), e mostra a porcentagem de cada tipo de medalha conquistada.
- Depois, selecionei a dimensão **Medal Type** na viwer **Medals**
- Por fim, selecionei a medida **Count** da viwer **Medals**

[OBERSEVAÇÃO]: Eu poderia ter criado esse look como uma tabela dentro do drill_fields do Quarto Look (visualização única), porém foi feito dessa forma para poder testar o gráfico de pizza

</details>

<details>
  <summary>Dúvidas</summary>

1. É comum usar filtros diretamente no explore (tendo em vista que esses filtros serão aplicados para todos os dash) ou é mais comum criar filtros dentro do próprio dash?
2. Quando que um filtro direto no explorer seria útil?
3. É normal que, quando eu clico em um dado para detalhamento (drill_field) apareça como google Maps e Tabela, ou foi por causa de alguma configuração que eu fiz?

</details>
