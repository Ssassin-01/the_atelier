import '../models/recipe.dart';
import '../models/component.dart';
import '../models/ingredient.dart';
import '../models/step.dart';

List<Recipe> getMockRecipes() {
  return [
    Recipe(
      id: 'pumpkin-dessert',
      name: 'Pumpkin Porridge Dessert',
      description:
          'A sophisticated multi-layered dessert featuring kabocha cream, mochi, and roasted rice textures.',
      mainImageUrl: 'assets/images/pumpkin_dessert.png',
      createdAt: DateTime.now(),
      tags: ['Seasonal', 'Signature'],
      components: [
        RecipeComponent(
          title: 'A. Pumpkin Cream',
          imageUrl: 'assets/images/pumpkin_cream.png',
          ingredients: [
            Ingredient(name: 'Frozen Kabocha', amount: '300', unit: 'g'),
            Ingredient(name: 'Milk', amount: '90', unit: 'g'),
            Ingredient(name: 'Heavy Cream', amount: '60', unit: 'g'),
            Ingredient(name: 'Egg Yolks', amount: '22', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '15', unit: 'g'),
            Ingredient(name: 'Salt', amount: '1', unit: 'g'),
            Ingredient(name: 'Cinnamon', amount: '0.3', unit: 'g'),
            Ingredient(name: 'Sheet Gelatin', amount: '2', unit: 'g'),
          ],
          steps: [
            RecipeStep(
              description:
                  'Steam kabocha (170°C for 20m), scoop out flesh and puree.',
            ),
            RecipeStep(
              description: 'Heat milk and heavy cream until steam rises.',
            ),
            RecipeStep(
              description: 'Whisk egg yolks, sugar, and salt together.',
            ),
            RecipeStep(
              description:
                  'Gradually pour hot liquid into yolks and heat to 82°C.',
            ),
            RecipeStep(description: 'Add soaked gelatin and emulsify.'),
            RecipeStep(description: 'Mix with pumpkin puree and blend smooth.'),
          ],
        ),
        RecipeComponent(
          title: 'B. Mini Rice Balls',
          imageUrl: 'assets/images/mini_mochi.png',
          ingredients: [
            Ingredient(
              name: 'Dry Glutinous Rice Flour',
              amount: '50',
              unit: 'g',
            ),
            Ingredient(name: 'Hot Water', amount: '32', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '4', unit: 'g'),
            Ingredient(name: 'Salt', amount: '0.5', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Mix flour, sugar, and salt.'),
            RecipeStep(
              description: 'Add hot water and knead to form a smooth dough.',
            ),
            RecipeStep(
              description:
                  'Divide into small 4g portions and roll into spheres.',
            ),
            RecipeStep(
              description:
                  'Boil until they float, then cook for 1 more minute.',
            ),
            RecipeStep(description: 'Immediately cool in ice water.'),
          ],
        ),
        RecipeComponent(
          title: 'C. Pumpkin Seed Tuile',
          imageUrl: 'assets/images/seed_tuile.png',
          ingredients: [
            Ingredient(name: 'Pumpkin Seeds', amount: '50', unit: 'g'),
            Ingredient(name: 'Butter', amount: '35', unit: 'g'),
            Ingredient(name: 'Icing Sugar', amount: '35', unit: 'g'),
            Ingredient(name: 'Rice Flour (Cake)', amount: '15', unit: 'g'),
            Ingredient(name: 'Egg White', amount: '30', unit: 'g'),
            Ingredient(name: 'Salt', amount: '1', unit: 'pinch'),
          ],
          steps: [
            RecipeStep(description: 'Finely chop the pumpkin seeds.'),
            RecipeStep(description: 'Cream softened butter with icing sugar.'),
            RecipeStep(
              description: 'Mix in egg whites followed by rice flour.',
            ),
            RecipeStep(
              description: 'Fold in the chopped seeds. Chill for 20m.',
            ),
            RecipeStep(description: 'Bake at 180°C for 8-11m until golden.'),
          ],
        ),
        RecipeComponent(
          title: 'D. Soybean Rice Crumble',
          imageUrl: 'assets/images/soybean_crumble.png',
          ingredients: [
            Ingredient(name: 'Rice Flour', amount: '35', unit: 'g'),
            Ingredient(name: 'Soybean Powder', amount: '20', unit: 'g'),
            Ingredient(name: 'Almond Flour', amount: '15', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '22', unit: 'g'),
            Ingredient(name: 'Cold Butter', amount: '32', unit: 'g'),
            Ingredient(name: 'Salt', amount: '1', unit: 'g'),
          ],
          steps: [
            RecipeStep(
              description:
                  'Sift together rice flour, soybean powder, and almond flour.',
            ),
            RecipeStep(
              description:
                  'Rub in cold cubed butter to create a coarse crumble texture.',
            ),
            RecipeStep(description: 'Freeze briefly to maintain shape.'),
            RecipeStep(
              description: 'Bake at 160°C for 12-15m, tossing halfway.',
            ),
          ],
        ),
        RecipeComponent(
          title: 'E. Rice Ice Cream',
          imageUrl: 'assets/images/rice_ice_cream.png',
          ingredients: [
            Ingredient(name: 'Cooked Glutinous Rice', amount: '50', unit: 'g'),
            Ingredient(name: 'Milk', amount: '350', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '40', unit: 'g'),
            Ingredient(name: 'Heavy Cream', amount: '84', unit: 'g'),
            Ingredient(name: 'Dextrose', amount: '25', unit: 'g'),
            Ingredient(name: 'Salt', amount: '0.5', unit: 'g'),
            Ingredient(name: 'Glucose Syrup', amount: '20', unit: 'g'),
            Ingredient(name: 'Roasted Brown Rice', amount: '7', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Simmer rice and milk in a pot to 50°C.'),
            RecipeStep(
              description: 'Add heavy cream, dextrose, syrup and heat to 82°C.',
            ),
            RecipeStep(
              description: 'Blend with an immersion blender until smooth.',
            ),
            RecipeStep(
              description:
                  'Fold in roasted brown rice for crunch. Churn in ice cream maker.',
            ),
          ],
        ),
      ],
    ),
    Recipe(
      id: '1',
      name: '스펠트밀 & 허니 사워도우',
      description: '고소한 스펠트밀과 천연 벌꿀을 배합하여 은은한 단맛과 깊은 발효 풍미를 느낄 수 있는 저온 숙성 사워도우 브레드입니다. 천연 발효종(르방)의 산미와 꿀의 향이 조화롭게 어우러집니다.',
      mainImageUrl: 'assets/images/sourdough.png',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['사워도우', '아티장'],
      components: [
        RecipeComponent(
          title: 'A. 르방 리프레시 (Levain Starter)',
          ingredients: [
            Ingredient(name: '강력분 (Bread Flour)', amount: '50', unit: 'g'),
            Ingredient(name: '물 (Water)', amount: '50', unit: 'g'),
            Ingredient(name: '사워도우 원종 (Starter)', amount: '10', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: '소독한 유리병에 원종과 미지근한 물을 넣어 완전히 풀어준 뒤 강력분을 넣고 덩어리가 없을 때까지 섞습니다.'),
            RecipeStep(description: '24~26°C 온도의 따뜻한 곳에서 부피가 2.5~3배로 부풀어 오를 때까지 약 4~5시간 동안 발효시켜 활성화합니다.'),
          ],
        ),
        RecipeComponent(
          title: 'B. 사워도우 본 반죽 (Main Dough)',
          ingredients: [
            Ingredient(name: '스펠트밀 가루 (Spelt Flour)', amount: '150', unit: 'g', isFlour: true),
            Ingredient(name: '강력분 (Bread Flour)', amount: '350', unit: 'g', isFlour: true),
            Ingredient(name: '물 (Water)', amount: '360', unit: 'g'),
            Ingredient(name: '천연 벌꿀 (Honey)', amount: '25', unit: 'g'),
            Ingredient(name: '바다 소금 (Sea Salt)', amount: '10', unit: 'g'),
            Ingredient(name: '활성 르방 (Fresh Levain)', amount: '100', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: '스펠트밀, 강력분, 물, 벌꿀을 믹싱 볼에 넣고 가루가 안 보일 때까지 날가루 없이 잘 혼합한 후 45분간 오토리즈(휴지)를 거칩니다.'),
            RecipeStep(description: '오토리즈가 끝나면 활성화된 르방을 넣고 반죽 표면이 매끄러워질 때까지 저속으로 약 3분간 섞어줍니다.'),
            RecipeStep(description: '소금을 넣고 글루텐이 중상 단계(약 80%)까지 형성되도록 본 반죽을 완료합니다.'),
            RecipeStep(description: '실온 1차 발효 중 30분 간격으로 총 3회 폴딩(늘여접기)을 수행하여 반죽의 구조와 가스 보유력을 강화합니다.'),
            RecipeStep(description: '실온에서 1차 발효가 총 4시간 정도 진행되면 반죽을 원하는 크기로 분할하여 둥글리기 한 후 20분간 중간 휴지합니다.'),
            RecipeStep(description: '반죽을 타원형 또는 원형으로 최종 성형하여 라이스 플라워를 뿌린 발효 바구니(반네톤)에 담고, 4°C 냉장고에서 12~16시간 저온 숙성합니다.'),
            RecipeStep(description: '240°C로 예열된 오븐에 무쇠 솥과 함께 스팀을 주어 25분간 뚜껑을 덮고 구운 후, 뚜껑을 열고 온도를 220°C로 낮춰 15분간 더 구워 바삭한 크러스트를 완성합니다.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '2',
      name: '라벤더 레몬 마들렌',
      description: '프랑스산 고메 버터와 향긋한 유기농 라벤더, 신선한 레몬 제스트가 만나 티타임의 품격을 높여주는 클래식 페이스트리입니다. 반죽을 하루 동안 숙성하여 촉촉하고 깊은 맛을 냅니다.',
      mainImageUrl: 'assets/images/madeleine.png',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['제과', '티타임'],
      components: [
        RecipeComponent(
          title: 'A. 마들렌 반죽 (Batter)',
          ingredients: [
            Ingredient(name: '박력분 (Cake Flour)', amount: '100', unit: 'g', isFlour: true),
            Ingredient(name: '백설탕 (Sugar)', amount: '90', unit: 'g'),
            Ingredient(name: '무염 고메 버터 (Butter)', amount: '100', unit: 'g'),
            Ingredient(name: '신선한 계란 (Eggs)', amount: '100', unit: 'g'),
            Ingredient(name: '베이킹파우더 (Baking Powder)', amount: '3', unit: 'g'),
            Ingredient(name: '레몬 제스트 (Lemon Zest)', amount: '2', unit: 'g'),
            Ingredient(name: '식용 건조 라벤더 (Lavender)', amount: '1', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: '냄비에 분량의 무염 버터와 건조 라벤더를 넣고 녹인 뒤 약 50°C 정도로 따뜻하게 유지하면서 라벤더 향을 우려냅니다.'),
            RecipeStep(description: '믹싱볼에 계란과 설탕을 넣고 거품기로 설탕이 사각거리지 않고 완전히 녹을 때까지 가볍게 섞어줍니다.'),
            RecipeStep(description: '박력분과 베이킹파우더를 함께 체 쳐서 달걀 혼합물에 넣고 레몬 제스트를 추가해 거품기로 매끄러워질 때까지 섞습니다.'),
            RecipeStep(description: '따뜻하게 유지한 라벤더 버터를 반죽에 3~4번에 나누어 부으며 버터가 겉돌지 않고 완전히 흡수될 때까지 부드럽게 섞습니다.'),
            RecipeStep(description: '완성된 반죽의 표면에 밀착되게 랩을 씌워 냉장고에서 12시간 이상 충분히 휴지(숙성)시킵니다.'),
            RecipeStep(description: '마들렌 팬에 녹인 버터를 바르고 밀가루 코팅을 마친 뒤 휴지된 반죽을 짤주머니에 담아 80% 정도 일정한 양으로 패닝합니다.'),
            RecipeStep(description: '190°C로 예열된 오븐에서 마들렌 배꼽이 부풀어 오르고 테두리가 황금빛을 띨 때까지 11~13분간 구워냅니다.'),
          ],
        ),
        RecipeComponent(
          title: 'B. 라벤더 글레이즈 (Lavender Glaze)',
          ingredients: [
            Ingredient(name: '슈가파우더 (Powdered Sugar)', amount: '80', unit: 'g'),
            Ingredient(name: '라벤더 우린 티 (Lavender Tea)', amount: '15', unit: 'g'),
            Ingredient(name: '신선한 레몬즙 (Lemon Juice)', amount: '2', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: '슈가파우더에 진하게 우린 따뜻한 라벤더 티와 상큼한 레몬즙을 넣고 덩어리가 없도록 매끄럽게 저어 섞어 줍니다.'),
            RecipeStep(description: '오븐에서 꺼내 식힘망 위에서 한김 식힌 따뜻한 마들렌의 앞면을 글레이즈에 디핑하거나 붓으로 얇게 코팅합니다.'),
            RecipeStep(description: '글레이즈가 투명하고 단단하게 굳어 마들렌 표면에 코팅될 때까지 실온에서 약 15~20분간 건조시킵니다.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '3',
      name: '전통 프랑스 바게트',
      description: '전통 프랑스식 바게트로, 폴리쉬(Poolish) 액종을 사용하여 기공이 풍부하고 겉은 바삭하며 속은 쫄깃한 식감을 완성합니다. 긴 시간 천천히 발효시켜 밀가루 본연의 단맛과 풍미를 극한으로 이끌어냅니다.',
      mainImageUrl: 'assets/images/baguette.png',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      tags: ['빵류', '아티장'],
      components: [
        RecipeComponent(
          title: 'A. 폴리쉬 액종 (Poolish Starter)',
          ingredients: [
            Ingredient(name: '프랑스 T55 밀가루 (Flour)', amount: '150', unit: 'g'),
            Ingredient(name: '물 (Water)', amount: '150', unit: 'g'),
            Ingredient(name: '인스턴트 드라이 이스트 (Yeast)', amount: '0.2', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: '미지근한 물에 이스트를 넣어 완전히 풀어준 뒤 프랑스 T55 밀가루를 섞어 덩어리 없게 개어줍니다.'),
            RecipeStep(description: '실온(20~22°C)에서 약 12시간 동안 발효시켜 부피가 크게 늘어나고 거품 기공이 활발히 뿜어져 나오는 액종 상태로 만듭니다.'),
          ],
        ),
        RecipeComponent(
          title: 'B. 바게트 본 반죽 (Main Dough)',
          ingredients: [
            Ingredient(name: '프랑스 T55 밀가루 (Flour)', amount: '350', unit: 'g', isFlour: true),
            Ingredient(name: '물 (Water)', amount: '200', unit: 'g'),
            Ingredient(name: '천일염 소금 (Salt)', amount: '10', unit: 'g'),
            Ingredient(name: '인스턴트 이스트 (Yeast)', amount: '1', unit: 'g'),
            Ingredient(name: '활성 폴리쉬 액종 (Active Poolish)', amount: '300', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: '믹싱 볼에 완성된 폴리쉬 액종, 물, 밀가루, 이스트를 넣어 한 덩어리로 뭉쳐지면 20분간 오토리즈합니다.'),
            RecipeStep(description: '오토리즈 후 소금을 넣고 본격적인 믹싱을 진행하여 글루텐 막이 부드럽게 형성되는 상태까지 도달하게 합니다.'),
            RecipeStep(description: '반죽을 실온에서 2시간 동안 1차 발효시키며, 발효 중간 45분과 90분 시점에 사면접기(Stretch & Fold)를 수행합니다.'),
            RecipeStep(description: '발효가 완료되면 반죽을 250g씩 분할하여 가볍게 가스를 빼고 원통형으로 둥글린 뒤 20분간 벤치타임을 가집니다.'),
            RecipeStep(description: '반죽을 길게 밀어 삼단접기를 한 뒤 캔버스 천 위에 올려 흐트러지지 않게 고정하고, 45분간 실온 최종 발효합니다.'),
            RecipeStep(description: '예열된 베이킹 스톤 위에 반죽을 얹고 면도칼로 5개의 사선 칼집(쿠프)을 얇고 균일하게 넣어 줍니다.'),
            RecipeStep(description: '스팀 기능이 있는 오븐에 넣거나 뜨거운 자갈에 물을 끼얹어 스팀을 준 후, 240°C에서 22~25분간 황금빛 크러스트가 될 때까지 구워냅니다.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '4',
      name: '로즈마리 올리브 오일 케이크',
      description: '신선한 유기농 로즈마리와 최고급 엑스트라 버진 올리브 오일을 듬뿍 사용하여 한 입 머금었을 때 깊은 허브 향과 촉촉한 식감이 입안 가득 퍼지는 이탈리아식 정통 디저트 케이크입니다.',
      mainImageUrl: 'assets/images/cake.png',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      tags: ['케이크', '디저트'],
      components: [
        RecipeComponent(
          title: 'A. 로즈마리 오일 베이스 (Infused Oil)',
          ingredients: [
            Ingredient(name: '엑스트라 버진 올리브 오일 (Olive Oil)', amount: '120', unit: 'g'),
            Ingredient(name: '신선한 생 로즈마리 (Fresh Rosemary)', amount: '3', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: '작은 냄비에 올리브 오일과 물기를 말린 생 로즈마리를 넣고 약불에서 아주 서서히 데워 로즈마리 향을 오일에 우려냅니다.'),
            RecipeStep(description: '오일 온도가 60°C에 도달하면 불을 끄고 그대로 식힌 뒤 로즈마리 줄기는 건져내어 향이 밴 올리브 오일만 준비합니다.'),
          ],
        ),
        RecipeComponent(
          title: 'B. 케이크 반죽 및 굽기 (Cake Batter)',
          ingredients: [
            Ingredient(name: '박력분 밀가루 (Cake Flour)', amount: '200', unit: 'g', isFlour: true),
            Ingredient(name: '백설탕 (White Sugar)', amount: '150', unit: 'g'),
            Ingredient(name: '플레인 요거트 (Plain Yogurt)', amount: '100', unit: 'g'),
            Ingredient(name: '신선한 달걀 (Eggs)', amount: '150', unit: 'g'),
            Ingredient(name: '곱게 다진 로즈마리 잎 (Rosemary)', amount: '2', unit: 'g'),
            Ingredient(name: '베이킹파우더 (Baking Powder)', amount: '5', unit: 'g'),
            Ingredient(name: '베이킹소다 (Baking Soda)', amount: '1.5', unit: 'g'),
            Ingredient(name: '소금 (Salt)', amount: '2', unit: 'g'),
            Ingredient(name: '준비된 로즈마리 오일 (Infused Oil)', amount: '120', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: '믹싱볼에 신선한 달걀과 설탕을 넣어 거품기나 핸드믹서로 미색이 돌고 풍성한 리본 자국이 남을 때까지 휘핑합니다.'),
            RecipeStep(description: '달걀 거품이 죽지 않도록 주의하며 향을 우린 올리브 오일과 플레인 요거트를 조금씩 나누어 넣으며 가볍게 섞습니다.'),
            RecipeStep(description: '박력분, 베이킹파우더, 베이킹소다, 소금을 함께 체 쳐서 오일 혼합물에 넣고 주극으로 날가루가 없을 때까지 부드럽게 섞습니다.'),
            RecipeStep(description: '아주 미세하게 곱게 다진 신선한 로즈마리 잎을 반죽에 고르게 흩뿌려 넣고 가볍게 1~2바퀴 혼합하여 향을 더합니다.'),
            RecipeStep(description: '유지나 유선지를 깐 18cm 원형 틀에 반죽을 조심히 부어준 후 바닥에 탁 쳐서 큰 기포를 정리합니다.'),
            RecipeStep(description: '175°C로 예열된 오븐에 넣고 약 40~45분간 구워내며, 꼬치로 가운데를 찔렀을 때 반죽이 묻어나오지 않으면 오븐에서 꺼냅니다.'),
            RecipeStep(description: '틀째로 10분간 식힌 후 뒤집어 식힘망에 올리고, 케이크가 완전히 식으면 슈가파우더를 체 쳐 뿌려 데코레이션합니다.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '5',
      name: '브라운 버터 초콜릿 쿠키',
      description: '버터를 갈색빛이 돌 때까지 태워 헤이즐넛향의 풍미를 극대화하고, 최고급 발로나 다크 초콜릿 청크와 말돈 소금을 얹어 구워낸 겉바속촉의 정석이자 아뜰리에의 시그니처 쿠키입니다.',
      mainImageUrl: 'assets/images/cookies.png',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['쿠키', '시그니처'],
      components: [
        RecipeComponent(
          title: 'A. 쿠키 도우 (Cookie Dough)',
          ingredients: [
            Ingredient(name: '중력분 밀가루 (All-Purpose Flour)', amount: '220', unit: 'g', isFlour: true),
            Ingredient(name: '유기농 황설탕 (Brown Sugar)', amount: '130', unit: 'g'),
            Ingredient(name: '백설탕 (White Sugar)', amount: '70', unit: 'g'),
            Ingredient(name: '무염 버터 (Unsalted Butter)', amount: '150', unit: 'g'),
            Ingredient(name: '다크 초콜릿 70% 청크 (Chocolate)', amount: '150', unit: 'g'),
            Ingredient(name: '신선한 계란 (Egg)', amount: '55', unit: 'g'),
            Ingredient(name: '달걀노른자 (Egg Yolk)', amount: '18', unit: 'g'),
            Ingredient(name: '베이킹소다 (Baking Soda)', amount: '3', unit: 'g'),
            Ingredient(name: '바닐라 익스트랙 (Vanilla)', amount: '5', unit: 'g'),
            Ingredient(name: '말돈 플랫 바다 소금 (Maldon Salt)', amount: '2', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: '냄비에 무염 버터를 넣고 중불에서 끓여 수분을 날리며 버터 찌꺼기가 갈색으로 변하고 고소한 견과류 향이 날 때까지 태웁니다.'),
            RecipeStep(description: '완성된 브라운 버터를 냄비에서 스테인리스 볼로 옮겨 담아 한김 식히고 미지근한 온도(약 40°C)로 조절합니다.'),
            RecipeStep(description: '식힌 브라운 버터에 황설탕과 백설탕을 넣고 서걱거리는 소리가 잦아들 때까지 거품기로 약 2분간 충분히 섞어 줍니다.'),
            RecipeStep(description: '계란, 달걀노른자, 바닐라 익스트랙을 버터 혼합물에 넣고 반죽이 밝은 베이지색이 되며 유화될 때까지 저어 크림화합니다.'),
            RecipeStep(description: '중력분과 베이킹소다를 한데 체 쳐 넣고 스패튤러로 자르듯이 섞어 가루가 약간 남아있을 때 다크 초콜릿 청크 80%를 넣고 한 덩이로 뭉칩니다.'),
            RecipeStep(description: '완성된 쿠키 반죽을 비닐이나 밀폐 용기에 담아 냉장고에서 최소 2시간에서 24시간 동안 저온 숙성(휴지)시킵니다.'),
            RecipeStep(description: '반죽을 60g씩 떼어 내어 가볍게 둥글려 오븐 팬에 간격을 넉넉히 두고 올린 뒤 남겨둔 초콜릿 청크를 쿠키 위에 장식하고 말돈 소금을 손가락으로 부수어 살짝 뿌립니다.'),
            RecipeStep(description: '180°C로 예열된 오븐에서 가장자리는 갈색빛이 돌며 단단하고 가운데는 아직 촉촉하게 말랑할 때까지 10~12분간 구워 식혀냅니다.'),
          ],
        ),
      ],
    ),
  ];
}
