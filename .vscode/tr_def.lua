---@meta
---@diagnostic disable: missing-fields

---@class tr.key
---@class tr.key_prefix

---@class tr.keys
local keys = {
    ---@class action_metadata: tr.key_prefix
    action_metadata = {
        --<span style="color:#6699CC;">English</span>: %s DEG<br><span style="color:#6699CC;">简体中文</span>: %s 度<br><span style="color:#6699CC;">日本語</span>: %s度<br><span style="color:#6699CC;">한국어</span>: %s도<br>
        ---@type tr.key
        degrees = {},
        --<span style="color:#6699CC;">English</span>: Disable<br><span style="color:#6699CC;">简体中文</span>: 禁用<br><span style="color:#6699CC;">日本語</span>: 次を無効化<br><span style="color:#6699CC;">한국어</span>: 다음 끄기<br>
        ---@type tr.key
        disables = {},
        --<span style="color:#6699CC;">English</span>: Draws<br><span style="color:#6699CC;">简体中文</span>: 抽取法术<br><span style="color:#6699CC;">日本語</span>: ドロー<br><span style="color:#6699CC;">한국어</span>: 드로우<br>
        ---@type tr.key
        draws = {},
        --<span style="color:#6699CC;">English</span>: Enable<br><span style="color:#6699CC;">简体中文</span>: 启用<br><span style="color:#6699CC;">日本語</span>: 次を有効化<br><span style="color:#6699CC;">한국어</span>: 다음 켜기<br>
        ---@type tr.key
        enables = {},
        --<span style="color:#6699CC;">English</span>: Friendly Fire<br><span style="color:#6699CC;">简体中文</span>: 友方伤害<br><span style="color:#6699CC;">日本語</span>: フレンドリーファイア<br><span style="color:#6699CC;">한국어</span>: 아군 사격<br>
        ---@type tr.key
        friendly_fire = {},
        --<span style="color:#6699CC;">English</span>: Proj. Gravity<br><span style="color:#6699CC;">简体中文</span>: 投射物重力<br><span style="color:#6699CC;">日本語</span>: 放射物の重力<br><span style="color:#6699CC;">한국어</span>: 발사체 중력<br>
        ---@type tr.key
        gravity = {},
        --<span style="color:#6699CC;">English</span>: Lifetime Add<br><span style="color:#6699CC;">简体中文</span>: 存在时间修正<br><span style="color:#6699CC;">日本語</span>: 寿命追加<br><span style="color:#6699CC;">한국어</span>: 수명 추가<br>
        ---@type tr.key
        lifetime_add = {},
        --<span style="color:#6699CC;">English</span>: Lifetime Limit<br><span style="color:#6699CC;">简体中文</span>: 存在时间限制<br><span style="color:#6699CC;">日本語</span>: 寿命の限界<br><span style="color:#6699CC;">한국어</span>: 수명 제한<br>
        ---@type tr.key
        lifetime_cap = {},
        --<span style="color:#6699CC;">English</span>: Max Uses<br><span style="color:#6699CC;">简体中文</span>: 最大使用次数<br><span style="color:#6699CC;">日本語</span>: 最大使用回数<br><span style="color:#6699CC;">한국어</span>: 최대 사용 횟수<br>
        ---@type tr.key
        max_uses = {},
        --<span style="color:#6699CC;">English</span>: Friction Coeff<br><span style="color:#6699CC;">简体中文</span>: 阻力系数<br><span style="color:#6699CC;">日本語</span>: 摩擦係数<br><span style="color:#6699CC;">한국어</span>: 마찰 계수<br>
        ---@type tr.key
        proj_air_friction = {},
        --<span style="color:#6699CC;">English</span>: Projectile<br><span style="color:#6699CC;">简体中文</span>: 投射物<br><span style="color:#6699CC;">日本語</span>: 放射物<br><span style="color:#6699CC;">한국어</span>: 발사체<br>
        ---@type tr.key
        proj_data = {},
        --<span style="color:#6699CC;">English</span>: Low Speed Limit<br><span style="color:#6699CC;">简体中文</span>: 速度底限<br><span style="color:#6699CC;">日本語</span>: 速度下限<br><span style="color:#6699CC;">한국어</span>: 속도 하한<br>
        ---@type tr.key
        proj_die_on_low_velocity = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Curse)<br><span style="color:#6699CC;">简体中文</span>: 诅咒伤害<br><span style="color:#6699CC;">日本語</span>: 呪いダメージ<br><span style="color:#6699CC;">한국어</span>: 저주 대미지<br>
        ---@type tr.key
        proj_dmg_curse = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Drill)<br><span style="color:#6699CC;">简体中文</span>: 穿凿伤害<br><span style="color:#6699CC;">日本語</span>: ドリルダメージ<br><span style="color:#6699CC;">한국어</span>: 관통 대미지<br>
        ---@type tr.key
        proj_dmg_drill = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Electric)<br><span style="color:#6699CC;">简体中文</span>: 电击伤害<br><span style="color:#6699CC;">日本語</span>: 電撃ダメージ<br><span style="color:#6699CC;">한국어</span>: 전기 대미지<br>
        ---@type tr.key
        proj_dmg_electricity = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Explosion)<br><span style="color:#6699CC;">简体中文</span>: 爆炸伤害<br><span style="color:#6699CC;">日本語</span>: 爆破ダメージ<br><span style="color:#6699CC;">한국어</span>: 폭발 대미지<br>
        ---@type tr.key
        proj_dmg_explosion = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Fire)<br><span style="color:#6699CC;">简体中文</span>: 火焰伤害<br><span style="color:#6699CC;">日本語</span>: 炎ダメージ<br><span style="color:#6699CC;">한국어</span>: 화염 대미지<br>
        ---@type tr.key
        proj_dmg_fire = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Healing)<br><span style="color:#6699CC;">简体中文</span>: 治疗伤害<br><span style="color:#6699CC;">日本語</span>: 回復ダメージ<br><span style="color:#6699CC;">한국어</span>: 회복 대미지<br>
        ---@type tr.key
        proj_dmg_healing = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Holy)<br><span style="color:#6699CC;">简体中文</span>: 神圣伤害<br><span style="color:#6699CC;">日本語</span>: 神聖ダメージ<br><span style="color:#6699CC;">한국어</span>: 신성 대미지<br>
        ---@type tr.key
        proj_dmg_holy = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Ice)<br><span style="color:#6699CC;">简体中文</span>: 冰冻伤害<br><span style="color:#6699CC;">日本語</span>: 氷ダメージ<br><span style="color:#6699CC;">한국어</span>: 얼음 대미지<br>
        ---@type tr.key
        proj_dmg_ice = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Melee)<br><span style="color:#6699CC;">简体中文</span>: 近战伤害<br><span style="color:#6699CC;">日本語</span>: 近接ダメージ<br><span style="color:#6699CC;">한국어</span>: 근접 대미지<br>
        ---@type tr.key
        proj_dmg_melee = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Poison)<br><span style="color:#6699CC;">简体中文</span>: 紫毒伤害<br><span style="color:#6699CC;">日本語</span>: 毒ダメージ<br><span style="color:#6699CC;">한국어</span>: 독 대미지<br>
        ---@type tr.key
        proj_dmg_poison = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Projectile)<br><span style="color:#6699CC;">简体中文</span>: 投射物伤害<br><span style="color:#6699CC;">日本語</span>: 放射物ダメージ<br><span style="color:#6699CC;">한국어</span>: 발사체 대미지<br>
        ---@type tr.key
        proj_dmg_projectile = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Radioactive)<br><span style="color:#6699CC;">简体中文</span>: 绿毒伤害<br><span style="color:#6699CC;">日本語</span>: 汚染ダメージ<br><span style="color:#6699CC;">한국어</span>: 독성 대미지<br>
        ---@type tr.key
        proj_dmg_radioactive = {},
        --<span style="color:#6699CC;">English</span>: Dmg. (Slice)<br><span style="color:#6699CC;">简体中文</span>: 切割伤害<br><span style="color:#6699CC;">日本語</span>: スライスダメージ<br><span style="color:#6699CC;">한국어</span>: 베기 대미지<br>
        ---@type tr.key
        proj_dmg_slice = {},
        --<span style="color:#6699CC;">English</span>: Expl. Damage<br><span style="color:#6699CC;">简体中文</span>: 爆炸伤害<br><span style="color:#6699CC;">日本語</span>: 爆破ダメージ<br><span style="color:#6699CC;">한국어</span>: 폭발 대미지<br>
        ---@type tr.key
        proj_expl_damage = {},
        --<span style="color:#6699CC;">English</span>: Expl. Shooter Prot.<br><span style="color:#6699CC;">简体中文</span>: 爆炸无自伤<br><span style="color:#6699CC;">日本語</span>: 詠唱者に安全な爆発<br><span style="color:#6699CC;">한국어</span>: 시전자 안전한 폭발<br>
        ---@type tr.key
        proj_expl_dont_dmg_shooter = {},
        --<span style="color:#6699CC;">English</span>: Expl. Enabled<br><span style="color:#6699CC;">简体中文</span>: 启用爆炸<br><span style="color:#6699CC;">日本語</span>: 爆発の有無<br><span style="color:#6699CC;">한국어</span>: 폭발 여부<br>
        ---@type tr.key
        proj_expl_enabled = {},
        --<span style="color:#6699CC;">English</span>: Expl. Radius<br><span style="color:#6699CC;">简体中文</span>: 爆炸半径<br><span style="color:#6699CC;">日本語</span>: 爆破範囲<br><span style="color:#6699CC;">한국어</span>: 폭발 반경<br>
        ---@type tr.key
        proj_expl_radius = {},
        --<span style="color:#6699CC;">English</span>: Friendly Fire<br><span style="color:#6699CC;">简体中文</span>: 友方伤害<br><span style="color:#6699CC;">日本語</span>: 味方攻撃可能<br><span style="color:#6699CC;">한국어</span>: 아군 사격<br>
        ---@type tr.key
        proj_friendly_fire = {},
        --<span style="color:#6699CC;">English</span>: Gravity<br><span style="color:#6699CC;">简体中文</span>: 重力<br><span style="color:#6699CC;">日本語</span>: 重力<br><span style="color:#6699CC;">한국어</span>: 중력<br>
        ---@type tr.key
        proj_gravity = {},
        --<span style="color:#6699CC;">English</span>: Spread (Innate)<br><span style="color:#6699CC;">简体中文</span>: 固有散射<br><span style="color:#6699CC;">日本語</span>: 拡散（自身の）<br><span style="color:#6699CC;">한국어</span>: 확산 (자체)<br>
        ---@type tr.key
        proj_innate_spread = {},
        --<span style="color:#6699CC;">English</span>: Lifetime<br><span style="color:#6699CC;">简体中文</span>: 存在时间<br><span style="color:#6699CC;">日本語</span>: 寿命<br><span style="color:#6699CC;">한국어</span>: 수명<br>
        ---@type tr.key
        proj_lifetime = {},
        --<span style="color:#6699CC;">English</span>: Lifetime Limit<br><span style="color:#6699CC;">简体中文</span>: 存在时间限制<br><span style="color:#6699CC;">日本語</span>: 寿命の上限<br><span style="color:#6699CC;">한국어</span>: 수명 상한<br>
        ---@type tr.key
        proj_lifetime_cap = {},
        --<span style="color:#6699CC;">English</span>: Projectile #%s<br><span style="color:#6699CC;">简体中文</span>: 投射物 #%s<br><span style="color:#6699CC;">日本語</span>: 放射物 #%s<br><span style="color:#6699CC;">한국어</span>: 발사체 #%s<br>
        ---@type tr.key
        proj_nth_data = {},
        --<span style="color:#6699CC;">English</span>: Projectiles<br><span style="color:#6699CC;">简体中文</span>: 投射物数量<br><span style="color:#6699CC;">日本語</span>: 放射物<br><span style="color:#6699CC;">한국어</span>: 발사체<br>
        ---@type tr.key
        proj_num_projectiles = {},
        --<span style="color:#6699CC;">English</span>: Shooter Coll. Prot.<br><span style="color:#6699CC;">简体中文</span>: 自伤保护<br><span style="color:#6699CC;">日本語</span>: 詠唱者衝突防止時間<br><span style="color:#6699CC;">한국어</span>: 시전자 충돌 방지 시간<br>
        ---@type tr.key
        proj_shooter_collision_protection = {},
        --<span style="color:#6699CC;">English</span>: Speed<br><span style="color:#6699CC;">简体中文</span>: 速度<br><span style="color:#6699CC;">日本語</span>: スピード<br><span style="color:#6699CC;">한국어</span>: 속도<br>
        ---@type tr.key
        proj_speed = {},
        --<span style="color:#6699CC;">English</span>: Timer Time<br><span style="color:#6699CC;">简体中文</span>: 定时时间<br><span style="color:#6699CC;">日本語</span>: タイマー<br><span style="color:#6699CC;">한국어</span>: 타이머 수명<br>
        ---@type tr.key
        proj_timer_time = {},
        --<span style="color:#6699CC;">English</span>: Recoil<br><span style="color:#6699CC;">简体中文</span>: 后座力<br><span style="color:#6699CC;">日本語</span>: 反動<br><span style="color:#6699CC;">한국어</span>: 반동<br>
        ---@type tr.key
        recoil = {},
        --<span style="color:#6699CC;">English</span>: Proj. Speed<br><span style="color:#6699CC;">简体中文</span>: 投射物速度倍数<br><span style="color:#6699CC;">日本語</span>: 放射物の速度<br><span style="color:#6699CC;">한국어</span>: 발사체 속도<br>
        ---@type tr.key
        speed_multiplier = {},
        --<span style="color:#6699CC;">English</span>: Spell Data<br><span style="color:#6699CC;">简体中文</span>: 法术数据<br><span style="color:#6699CC;">日本語</span>: 呪文データ<br><span style="color:#6699CC;">한국어</span>: 주문 데이터<br>
        ---@type tr.key
        spell_data = {},
        --<span style="color:#6699CC;">English</span>: Set to %s<br><span style="color:#6699CC;">简体中文</span>: 设置为 %s<br><span style="color:#6699CC;">日本語</span>: %sに設定<br><span style="color:#6699CC;">한국어</span>: %s(으)로 설정<br>
        ---@type tr.key
        value_set_to = {},
    },
    --<span style="color:#6699CC;">English</span>: Clear Projectile<br><span style="color:#6699CC;">简体中文</span>: 清除投射物<br><span style="color:#6699CC;">日本語</span>: 放射物を消去<br><span style="color:#6699CC;">한국어</span>: 발사체 지우기<br>
    ---@type tr.key
    clear_projectiles = {},
    --<span style="color:#6699CC;">English</span>: Spawn Convenient Wand\nRight-click to replace held wand with convenient wand<br><span style="color:#6699CC;">简体中文</span>: 一键生成神杖\n右键替换手中法杖为神杖<br><span style="color:#6699CC;">日本語</span>: 便利杖を生成\n右クリックで手持ちの杖を便利杖に置き換え<br><span style="color:#6699CC;">한국어</span>: 간편 완드 생성\n오른쪽 클릭으로 손에 든 완드를 간편 완드로 교체<br>
    ---@type tr.key
    convenient_wand = {},
    --<span style="color:#6699CC;">English</span>: Superflight<br><span style="color:#6699CC;">简体中文</span>: 超级飞行<br><span style="color:#6699CC;">日本語</span>: スーパー飛行<br><span style="color:#6699CC;">한국어</span>: 슈퍼 비행<br>
    ---@class tr.keys.creative_mode_flight: tr.key, tr.key_prefix
    creative_mode_flight = {
        --<span style="color:#6699CC;">English</span>: Hold Ctrl to fly faster. Hold Shift to fly through walls.\nUnfortunately, holding Ctrl and Shift at the same time does not make you fly through walls faster,\nbecause Ctrl + Shift + S and Ctrl + Shift + W has been taken by Component Explorer mod<br><span style="color:#6699CC;">简体中文</span>: 按住 Ctrl 以更快的速度飞行，按住 Shift 可以穿墙飞行\n遗憾的是，同时按住 Ctrl 和 Shift 并不能让你以更快的速度穿墙飞行，\n因为组件浏览器模组已经占用了 Ctrl + Shift + S 和 Ctrl + Shift + W。<br><span style="color:#6699CC;">日本語</span>: Ctrlキーを押して高速飛行、Shiftキーを押して壁抜けします。\n残念ながら、CtrlとShiftを同時に押して高速で壁抜けは不可能です。\nこれはCtrl + Shift + SとCtrl + Shift + Wが\nComponent Explorer modで既に使われているからです。<br><span style="color:#6699CC;">한국어</span>: Ctrl 키를 누르고 있으면 더 빨리 날 수 있음. Shift 키를 누르고 있으면 벽을 뚫고 날 수 있음.\n안타깝게도 Ctrl과 Shift 키를 동시에 누른다고 해서 벽을 더 빨리 뚫고 날아갈 수는 없음.\n이는 Ctrl + Shift + S와 Ctrl + Shift + W 조합이\nComponent Explorer 모드에서 이미 사용 중이기 때문.<br>
        ---@type tr.key
        desc = {},
        --<span style="color:#6699CC;">English</span>: Also note that in Debug mode holding Ctrl doesn't do anything<br><span style="color:#6699CC;">简体中文</span>: 此外请注意，如果开启游戏的 Debug 模式，按住 Ctrl 只会使你停下。<br><span style="color:#6699CC;">日本語</span>: またデバッグモードではCtrlキーを押しても何も起こらない点にも注意してください<br><span style="color:#6699CC;">한국어</span>: 또한 디버그 모드에서는 Ctrl 키를 누르더라도 아무 반응이 없으니 유의하세요<br>
        ---@type tr.key
        note_dev_exe = {},
    },
    --<span style="color:#6699CC;">English</span>: Damage Info<br><span style="color:#6699CC;">简体中文</span>: 伤害数值显示<br><span style="color:#6699CC;">日本語</span>: ダメージ情報<br><span style="color:#6699CC;">한국어</span>: 대미지 정보<br>
    ---@class tr.keys.damage_info: tr.key, tr.key_prefix
    damage_info = {
        --<span style="color:#6699CC;">English</span>: Damage Per Second: %s<br><span style="color:#6699CC;">简体中文</span>: 每秒伤害：%s<br><span style="color:#6699CC;">日本語</span>: 秒間ダメージ：%s<br><span style="color:#6699CC;">한국어</span>: 초당 대미지:<br>
        ---@type tr.key
        dps = {},
        --<span style="color:#6699CC;">English</span>: Total Damage: %d<br><span style="color:#6699CC;">简体中文</span>: 总伤害：%d<br><span style="color:#6699CC;">日本語</span>: 合計ダメージ：%d<br><span style="color:#6699CC;">한국어</span>: 총 대미지:%d<br>
        ---@type tr.key
        total_damage = {},
        --<span style="color:#6699CC;">English</span>: Total Projectile Damage: %d<br><span style="color:#6699CC;">简体中文</span>: 总投射物伤害：%d<br><span style="color:#6699CC;">日本語</span>: 合計放射物ダメージ：%d<br><span style="color:#6699CC;">한국어</span>: 총 발사체 대미지:%d<br>
        ---@type tr.key
        total_proj_dmg = {},
        --<span style="color:#6699CC;">English</span>: Total Projectiles: %d<br><span style="color:#6699CC;">简体中文</span>: 总投射物数量：%d<br><span style="color:#6699CC;">日本語</span>: 放射物の数：%d<br><span style="color:#6699CC;">한국어</span>: 발사체 개수:%d<br>
        ---@type tr.key
        total_projectiles_num = {},
    },
    --<span style="color:#6699CC;">English</span>: Creature to Target Dummy\nClick this button and then press %s to transform the creature closest to your mouse position<br><span style="color:#6699CC;">简体中文</span>: 转化生物为伤害测试假人\n点击此按钮后，按 %s 转化离鼠标指针最近的生物<br><span style="color:#6699CC;">日本語</span>: 生物をダミーに変換\nこのボタンをクリックしてから%sを押してカーソルから最も近い生物をダミーに変換<br><span style="color:#6699CC;">한국어</span>: 생물체를 더미로 만들기\n이 버튼을 누르고 %s을(를) 눌러 마우스 위치와 가장 가까운 생물체를 더미로 변환<br>
    ---@class tr.keys.dummy_transforming: tr.key, tr.key_prefix
    dummy_transforming = {
        --<span style="color:#6699CC;">English</span>: Transformed %s into a target dummy<br><span style="color:#6699CC;">简体中文</span>: 已将 %s 转化为伤害测试假人<br><span style="color:#6699CC;">日本語</span>: %sをダミーに変換しました<br><span style="color:#6699CC;">한국어</span>: %s을(를) 더미로 변환함<br>
        ---@type tr.key
        done = {},
        ---@class dummy_transforming.err: tr.key_prefix
        err = {
            --<span style="color:#6699CC;">English</span>: Error: Unable to transform a target dummy into a target dummy<br><span style="color:#6699CC;">简体中文</span>: 错误：无法将伤害测试假人转化为伤害测试假人<br><span style="color:#6699CC;">日本語</span>: エラー：ダミーはダミーに変換できません<br><span style="color:#6699CC;">한국어</span>: 오류: 더미를 더미로 변환시킬 수 없음<br>
            ---@type tr.key
            already_transformed = {},
            --<span style="color:#6699CC;">English</span>: Error: Unable to transform yourself into a target dummy<br><span style="color:#6699CC;">简体中文</span>: 错误：无法将玩家转化为伤害测试假人<br><span style="color:#6699CC;">日本語</span>: エラー：自分自身はダミーに変換できません<br><span style="color:#6699CC;">한국어</span>: 오류: 자기 자신을 더미로 변환시킬 수 없음<br>
            ---@type tr.key
            cant_transform_player = {},
            --<span style="color:#6699CC;">English</span>: Error: No creature found near your mouse position<br><span style="color:#6699CC;">简体中文</span>: 错误：鼠标指针附近没有合适的生物<br><span style="color:#6699CC;">日本語</span>: エラー：カーソルの近くに生物がありません<br><span style="color:#6699CC;">한국어</span>: 오류: 마우스 위치 근처에 생물체가 없음<br>
            ---@type tr.key
            no_target = {},
        },
    },
    ---@class general: tr.key_prefix
    general = {
        --<span style="color:#6699CC;">English</span>: %s f<br><span style="color:#6699CC;">简体中文</span>: %s 帧<br><span style="color:#6699CC;">日本語</span>: %s f<br><span style="color:#6699CC;">한국어</span>: %s f<br>
        ---@type tr.key
        frames = {},
        --<span style="color:#6699CC;">English</span>: Disable %s<br><span style="color:#6699CC;">简体中文</span>: 关 %s<br><span style="color:#6699CC;">日本語</span>: 無効化：%s<br><span style="color:#6699CC;">한국어</span>: 끄기: %s<br>
        ---@type tr.key
        option_disable = {},
        --<span style="color:#6699CC;">English</span>: Enable %s<br><span style="color:#6699CC;">简体中文</span>: 开 %s<br><span style="color:#6699CC;">日本語</span>: 有効化：%s<br><span style="color:#6699CC;">한국어</span>: 켜기: %s<br>
        ---@type tr.key
        option_enable = {},
        --<span style="color:#6699CC;">English</span>: (nothing here)<br><span style="color:#6699CC;">简体中文</span>: （空）<br><span style="color:#6699CC;">日本語</span>: （空）<br><span style="color:#6699CC;">한국어</span>: (아무것도 없음)<br>
        ---@type tr.key
        scroll_table_nothing = {},
    },
    --<span style="color:#6699CC;">English</span>: Completely heal\nShift + Click to fix your hp<br><span style="color:#6699CC;">简体中文</span>: 完全回复生命值\nShift + 点击锁定生命值<br><span style="color:#6699CC;">日本語</span>: 全回復\nShift + クリックで体力を固定<br><span style="color:#6699CC;">한국어</span>: 완전 회복\nShift + 클릭해서 체력을 고정<br>
    ---@class tr.keys.hp_fixer: tr.key, tr.key_prefix
    hp_fixer = {
        --<span style="color:#6699CC;">English</span>: Your HP is fixed to %s / %s\nRight-click to unfix it<br><span style="color:#6699CC;">简体中文</span>: 你的生命值已锁定为 %s / %s\n右键取消锁定<br><span style="color:#6699CC;">日本語</span>: 固定されている体力：%s / %s\n右クリックで固定解除<br><span style="color:#6699CC;">한국어</span>: 고정된 체력: %s / %s\n오른쪽 클릭으로 고정 해제<br>
        ---@type tr.key
        fixed_to = {},
    },
    ---@class main_gui: tr.key_prefix
    main_gui = {
        ---@class main_gui.entry_point: tr.key_prefix
        entry_point = {
            --<span style="color:#6699CC;">English</span>: Right-click to drag<br><span style="color:#6699CC;">简体中文</span>: 右键拖动此按钮<br>
            ---@type tr.key
            desc = {},
            --<span style="color:#6699CC;">English</span>: Hide Spell Lab<br><span style="color:#6699CC;">简体中文</span>: 隐藏法术实验室<br><span style="color:#6699CC;">日本語</span>: スペルラボ非表示<br><span style="color:#6699CC;">한국어</span>: 스펠 랩 숨기기<br>
            ---@type tr.key
            hide = {},
            --<span style="color:#6699CC;">English</span>: Show Spell Lab<br><span style="color:#6699CC;">简体中文</span>: 显示法术实验室<br><span style="color:#6699CC;">日本語</span>: スペルラボ表示<br><span style="color:#6699CC;">한국어</span>: 스펠 랩 표시<br>
            ---@type tr.key
            show = {},
        },
    },
    --<span style="color:#6699CC;">English</span>: Annoying Effects Immunity<br><span style="color:#6699CC;">简体中文</span>: 免疫部分负面效果<br><span style="color:#6699CC;">日本語</span>: デメリット効果無効<br><span style="color:#6699CC;">한국어</span>: 부정적인 상태 무효<br>
    ---@class tr.keys.no_annoying_effects: tr.key, tr.key_prefix
    no_annoying_effects = {
        --<span style="color:#6699CC;">English</span>: Immunity from (unstable) teleportisis, blindness, confusion, slower movement,\nfrozen, electrocution, drunk and glued<br><span style="color:#6699CC;">简体中文</span>: 免疫（不稳）传送、致盲、混乱、更慢移动、冻结、电击、醉酒、胶粘<br><span style="color:#6699CC;">日本語</span>: 瞬間移動（不安定）、盲目、混乱、移動速度低下、凍結、感電、 \n酔っ払い、のりにくっつくなどに対する免疫を獲得する<br><span style="color:#6699CC;">한국어</span>: 텔레포트 회피 (불안정), 실명, 혼란, 느린 이동, 빙결, 감전,\n취함 및 풀에 붙음으로 부터 면역을 얻음<br>
        ---@type tr.key
        desc = {},
    },
    --<span style="color:#6699CC;">English</span>: No recoil<br><span style="color:#6699CC;">简体中文</span>: 无后坐力<br><span style="color:#6699CC;">日本語</span>: 反動無効<br><span style="color:#6699CC;">한국어</span>: 반동 무효<br>
    ---@type tr.key
    no_recoil = {},
    --<span style="color:#6699CC;">English</span>: Delete Spell(s)<br><span style="color:#6699CC;">简体中文</span>: 删除法术<br><span style="color:#6699CC;">日本語</span>: 呪文削除<br><span style="color:#6699CC;">한국어</span>: 주문 삭제<br>
    ---@type tr.key
    operation_delete_action = {},
    --<span style="color:#6699CC;">English</span>: Delete Slot(s)<br><span style="color:#6699CC;">简体中文</span>: 删除法术槽<br><span style="color:#6699CC;">日本語</span>: スロット削除<br><span style="color:#6699CC;">한국어</span>: 슬롯 삭제<br>
    ---@type tr.key
    operation_delete_action_slot = {},
    --<span style="color:#6699CC;">English</span>: Promote Always-cast Spell<br><span style="color:#6699CC;">简体中文</span>: 取消始终施放<br><span style="color:#6699CC;">日本語</span>: 常時詠唱呪文に昇格<br><span style="color:#6699CC;">한국어</span>: 항상 시전 주문으로 승격<br>
    ---@type tr.key
    operation_demote_permanent_action = {},
    --<span style="color:#6699CC;">English</span>: Deselect<br><span style="color:#6699CC;">简体中文</span>: 取消选择<br><span style="color:#6699CC;">日本語</span>: 選択解除<br><span style="color:#6699CC;">한국어</span>: 선택 해제<br>
    ---@type tr.key
    operation_deselect = {},
    --<span style="color:#6699CC;">English</span>: Duplicate Spell(s)<br><span style="color:#6699CC;">简体中文</span>: 复制法术<br><span style="color:#6699CC;">日本語</span>: 呪文複製<br><span style="color:#6699CC;">한국어</span>: 주문 복제<br>
    ---@type tr.key
    operation_duplicate_action = {},
    --<span style="color:#6699CC;">English</span>: Move Spell(s)<br><span style="color:#6699CC;">简体中文</span>: 移动法术<br><span style="color:#6699CC;">日本語</span>: 呪文移動<br><span style="color:#6699CC;">한국어</span>: 주문 이동<br>
    ---@type tr.key
    operation_override_actions = {},
    --<span style="color:#6699CC;">English</span>: Demote Always-cast Spell<br><span style="color:#6699CC;">简体中文</span>: 设置始终施放<br><span style="color:#6699CC;">日本語</span>: 常時詠唱呪文を降格<br><span style="color:#6699CC;">한국어</span>: 항상 시전 주문에서 강등<br>
    ---@type tr.key
    operation_promote_permanent_action = {},
    --<span style="color:#6699CC;">English</span>: External Wand Operation<br><span style="color:#6699CC;">简体中文</span>: 外部法杖操作<br><span style="color:#6699CC;">日本語</span>: mod外の杖操作<br><span style="color:#6699CC;">한국어</span>: 모드 외 완드 작업<br>
    ---@type tr.key
    operation_read_from_wand = {},
    --<span style="color:#6699CC;">English</span>: Select<br><span style="color:#6699CC;">简体中文</span>: 选择<br><span style="color:#6699CC;">日本語</span>: 選択<br><span style="color:#6699CC;">한국어</span>: 선택<br>
    ---@type tr.key
    operation_select = {},
    --<span style="color:#6699CC;">English</span>: Put Spell(s)<br><span style="color:#6699CC;">简体中文</span>: 放置法术<br><span style="color:#6699CC;">日本語</span>: 呪文挿入<br><span style="color:#6699CC;">한국어</span>: 주문 넣기<br>
    ---@type tr.key
    operation_set_action = {},
    --<span style="color:#6699CC;">English</span>: Put Spell Group<br><span style="color:#6699CC;">简体中文</span>: 放置法术组合<br><span style="color:#6699CC;">日本語</span>: 呪文グループ挿入<br><span style="color:#6699CC;">한국어</span>: 주문 그룹 넣기<br>
    ---@type tr.key
    operation_set_action_group = {},
    --<span style="color:#6699CC;">English</span>: Swap Spell(s)<br><span style="color:#6699CC;">简体中文</span>: 交换法术<br><span style="color:#6699CC;">日本語</span>: 呪文入れ替え<br><span style="color:#6699CC;">한국어</span>: 주문 교체<br>
    ---@type tr.key
    operation_swap_actions = {},
    --<span style="color:#6699CC;">English</span>: {select}: Select\n{deselect}: Deselect\n{swap}: \n    If clicked slot is not selected: swap selected spell(s) to clicked slot\n    If clicked slot is selected: cycle selected spells\nThe above shortcuts also work in the wand box and spell group box\n{multi_select}: Multiple selection\n{expand_selection_left}: Expand selection on the left side\n{expand_selection_right}: Expand selection on the right side\nThe above shortcuts also work in the wand box\n{override}: move selected spell(s) to clicked slot\n{duplicate}: Duplicate Spell(s)\n{delete_action}: Delete spell\n{delete_slot}: Delete spell and shift following spells left\n{always_cast}: Promote/Demote always-cast spell\n{left_delete}: Delete a spell to the left\n{right_delete}: Delete a spell to the right\n{undo}: Undo\n{redo}: Redo<br><span style="color:#6699CC;">简体中文</span>: {select}：选中\n{deselect}：取消选中\n{swap}：\n    若点击槽位未选中：将已选择法术交换至此处\n    若点击槽位已选中：轮换已选择法术\n以上快捷键也可在法杖仓库与法术组合仓库页面使用\n{multi_select}：选中多个\n{expand_selection_left}：扩展左边的选区至此处\n{expand_selection_right}：扩展右边的选区至此处\n以上快捷键也可在法杖仓库页面使用\n{override}：将已选择法术移动至此处\n{duplicate}：复制法术\n{delete_action}：删除法术\n{delete_slot}：删除法术并将右侧法术左移\n{always_cast}：设置/取消始终施放\n{left_delete}：向左删除法术\n{right_delete}：向右删除法术\n{undo}：撤销操作\n{redo}：恢复操作<br><span style="color:#6699CC;">日本語</span>: {select}：選択\n{deselect}：選択解除\n{swap}：\n 選択済みではないスロットをクリックした場合：選択済みの呪文をクリックしたスロットと入れ替え\n 選択済みのスロットをクリックした場合：選択済みの呪文を順番に切り替え\n上記のショートカットは杖ボックスと呪文グループボックスでも使用可能\n{multi_select}：複数選択\n{expand_selection_left}：左へ選択範囲を拡張\n{expand_selection_right}：右へ選択範囲を拡張\n上記のショートカットは杖ボックスでも使用可能\n{override}：選択済みの呪文をクリックしたスロットへ移動\n{duplicate}：呪文複製\n{delete_action}：呪文削除\n{delete_slot}：呪文を削除し、後続の呪文を左へ詰める\n{always_cast}：常時詠唱の呪文に昇格/降格\n{left_delete}：左の呪文を削除\n{right_delete}：右の呪文を削除\n{undo}：取り消し\n{redo}：やり直し<br><span style="color:#6699CC;">한국어</span>: {select}: 선택\n{deselect}: 선택 해제\n{swap}: \n    클릭한 슬롯이 선택되지 않은 경우: 선택된 주문을 클릭한 슬롯과 교체\n    클릭한 슬롯이 선택된 경우: 선택된 주문을 순환시킴\n위의 단축키들은 완드 박드 및 주문 그룹 박스에서도 작동함\n{multi_select}: 다중 선택\n{expand_selection_left}: 왼쪽으로 선택 범위 확장\n{expand_selection_right}: 오른쪽으로 선택 범위 확장\n위의 단축키들은 완드 박드에서도 작동함\n{override}: 선택된 주문을 클릭한 슬롯으로 이동\n\n{duplicate}: 주문 복제\n{delete_action}: 주문 삭제\n{delete_slot}: 주문을 삭제하고 뒤따르는 주문들을 왼쪽으로 이동\n{always_cast}: 항상 시전 주문 승격/강등\n{left_delete}: 왼쪽에 있는 주문 삭제\n{right_delete}: 오른쪽에 있는 주문 삭제\n{undo}: 실행 취소\n{redo}: 다시 실행<br>
    ---@type tr.key
    shortcut_tips = {},
    --<span style="color:#6699CC;">English</span>: Wand Edit Panel Shortcuts<br><span style="color:#6699CC;">简体中文</span>: 法杖编辑面板快捷键<br><span style="color:#6699CC;">日本語</span>: 杖編集パネルのショートカット<br><span style="color:#6699CC;">한국어</span>: 완드 편집 패널 단축키<br>
    ---@type tr.key
    shortcut_tips_title = {},
    --<span style="color:#6699CC;">English</span>: Shot Effects<br><span style="color:#6699CC;">简体中文</span>: 射击效果<br><span style="color:#6699CC;">日本語</span>: ショット効果<br><span style="color:#6699CC;">한국어</span>: 샷 효과<br>
    ---@class tr.keys.shot_effects: tr.key, tr.key_prefix
    shot_effects = {
        ---@class shot_effects.desc: tr.key_prefix
        desc = {
            --<span style="color:#6699CC;">English</span>: You sense an increased chance of attaining critical hits.<br><span style="color:#6699CC;">简体中文</span>: 你感觉自己更容易打出暴击。<br><span style="color:#6699CC;">日本語</span>: クリティカル率が増加する。<br><span style="color:#6699CC;">한국어</span>: 치명타를 입힐 확률이 높아집니다.<br>
            ---@type tr.key
            bloody = {},
            --<span style="color:#6699CC;">English</span>: Your projectile spells have a chance to duplicate<br><span style="color:#6699CC;">简体中文</span>: 你的投射物法术一定几率复制<br><span style="color:#6699CC;">日本語</span>: あなたの放射物が複製される可能性がある。<br><span style="color:#6699CC;">한국어</span>: 발사체 주문이 일정 확률로 복제됩니다<br>
            ---@type tr.key
            duplicate_projectile = {},
            --<span style="color:#6699CC;">English</span>: You inflict more damage the more satiated you are<br><span style="color:#6699CC;">简体中文</span>: 越饱足时造成的伤害越高<br><span style="color:#6699CC;">日本語</span>: 胃袋が膨れているほど多くのダメージを与える。<br><span style="color:#6699CC;">한국어</span>: 배가 부를수록 더 큰 대미지를 입힙니다<br>
            ---@type tr.key
            food_clock = {},
            --<span style="color:#6699CC;">English</span>: Your spells deal 5x damage and have larger blast ranges.<br><span style="color:#6699CC;">简体中文</span>: 你的法术伤害 x5，并获得更大的爆炸半径。<br><span style="color:#6699CC;">日本語</span>: あなたの呪文が5倍ダメージを与え、更に大きな爆破範囲に広がる。<br><span style="color:#6699CC;">한국어</span>: 주문이 더 큰 폭발 범위를 가지고 5배 대미지를 가합니다<br>
            ---@type tr.key
            glass_cannon = {},
            --<span style="color:#6699CC;">English</span>: Your spells home towards yourself.<br><span style="color:#6699CC;">简体中文</span>: 你的法术会暂时追踪你自己。<br><span style="color:#6699CC;">日本語</span>: 自分の呪文が、少しだけ自分の方に向かって行く。<br><span style="color:#6699CC;">한국어</span>: 주문이 자기 자신을 향해 날아옵니다.<br>
            ---@type tr.key
            homing_shooter_wizard = {},
            --<span style="color:#6699CC;">English</span>: Your spells fly faster and have lower spread<br><span style="color:#6699CC;">简体中文</span>: 你的法术飞行更快、散射更小<br><span style="color:#6699CC;">日本語</span>: 自分の呪文の飛行速度が速くなって拡散幅が狭くなる。<br><span style="color:#6699CC;">한국어</span>: 주문의 탄속이 증가하고 확산은 낮아집니다<br>
            ---@type tr.key
            laser_aim = {},
            --<span style="color:#6699CC;">English</span>: you fire spells much slower<br><span style="color:#6699CC;">简体中文</span>: 你发射法术要慢上许多<br><span style="color:#6699CC;">日本語</span>: 呪文の詠唱間隔が伸びる。<br><span style="color:#6699CC;">한국어</span>: 주문의 연사 속도가 느려집니다.<br>
            ---@type tr.key
            personal_laser = {},
            --<span style="color:#6699CC;">English</span>: You gain additional chance to deal critical hits.<br><span style="color:#6699CC;">简体中文</span>: 你获得额外的暴击几率。<br><span style="color:#6699CC;">日本語</span>: クリティカルヒットを与える追加のチャンスを獲得する。<br><span style="color:#6699CC;">한국어</span>: 치명타 확률이 높아집니다.<br>
            ---@type tr.key
            risky_critical = {},
            --<span style="color:#6699CC;">English</span>: Your spells can hurt you!<br><span style="color:#6699CC;">简体中文</span>: 你自己的法术会对你自己造成伤害！<br><span style="color:#6699CC;">日本語</span>: 呪文が自分自身を傷つける！<br><span style="color:#6699CC;">한국어</span>: 당신의 주문이 당신을 해치게 됩니다!<br>
            ---@type tr.key
            twitchy = {},
        },
        --<span style="color:#6699CC;">English</span>: Stackable Max.<br><span style="color:#6699CC;">简体中文</span>: 最大叠加层数<br><span style="color:#6699CC;">日本語</span>: スタック最大数<br><span style="color:#6699CC;">한국어</span>: 중첩 가능 최대 수<br>
        ---@class tr.keys.shot_effects.max_count: tr.key, tr.key_prefix
        max_count = {
            --<span style="color:#6699CC;">English</span>: Infinity<br><span style="color:#6699CC;">简体中文</span>: 无限<br><span style="color:#6699CC;">日本語</span>: 無限<br><span style="color:#6699CC;">한국어</span>: 무한대<br>
            ---@type tr.key
            infinite = {},
        },
        --<span style="color:#6699CC;">English</span>: Provided by %s<br><span style="color:#6699CC;">简体中文</span>: 提供自%s<br><span style="color:#6699CC;">日本語</span>: 効果元：%s<br><span style="color:#6699CC;">한국어</span>: 효과 출처: %s<br>
        ---@class tr.keys.shot_effects.source_type: tr.key, tr.key_prefix
        source_type = {
            --<span style="color:#6699CC;">English</span>: Status<br><span style="color:#6699CC;">简体中文</span>: 效果<br><span style="color:#6699CC;">日本語</span>: 状態<br><span style="color:#6699CC;">한국어</span>: 상태<br>
            ---@type tr.key
            custom_effect = {},
            --<span style="color:#6699CC;">English</span>: Perk<br><span style="color:#6699CC;">简体中文</span>: 天赋<br><span style="color:#6699CC;">日本語</span>: 特典<br><span style="color:#6699CC;">한국어</span>: 능력<br>
            ---@type tr.key
            perk = {},
            --<span style="color:#6699CC;">English</span>: Status<br><span style="color:#6699CC;">简体中文</span>: 效果<br><span style="color:#6699CC;">日本語</span>: 状態<br><span style="color:#6699CC;">한국어</span>: 상태<br>
            ---@type tr.key
            status = {},
        },
        ---@class shot_effects.type: tr.key_prefix
        type = {
            --<span style="color:#6699CC;">English</span>: Extra Modifier<br><span style="color:#6699CC;">简体中文</span>: 额外修正<br><span style="color:#6699CC;">日本語</span>: 追加の修正<br><span style="color:#6699CC;">한국어</span>: 기타 조정자<br>
            ---@type tr.key
            extra_modifier = {},
            --<span style="color:#6699CC;">English</span>: Caster Effect<br><span style="color:#6699CC;">简体中文</span>: 施法者效果<br><span style="color:#6699CC;">日本語</span>: 詠唱者効果<br><span style="color:#6699CC;">한국어</span>: 시전자 효과<br>
            ---@type tr.key
            game_effect = {},
            --<span style="color:#6699CC;">English</span>: Cast Script<br><span style="color:#6699CC;">简体中文</span>: 施法脚本<br><span style="color:#6699CC;">日本語</span>: 詠唱スクリプト<br><span style="color:#6699CC;">한국어</span>: 시전 스크립트<br>
            ---@type tr.key
            shot_script = {},
        },
        --<span style="color:#6699CC;">English</span>: Ignore Stackable Maximums<br><span style="color:#6699CC;">简体中文</span>: 无视叠加层数限制<br><span style="color:#6699CC;">日本語</span>: スタック最大数を無視<br><span style="color:#6699CC;">한국어</span>: 중첩 가능 최대 수 무시<br>
        ---@type tr.key
        unsafe_count_allowed = {},
    },
    --<span style="color:#6699CC;">English</span>: Spell Group Box<br><span style="color:#6699CC;">简体中文</span>: 法术组合仓库<br><span style="color:#6699CC;">日本語</span>: 呪文グループボックス<br><span style="color:#6699CC;">한국어</span>: 주문 그룹 박스<br>
    ---@class tr.keys.spell_group_box: tr.key, tr.key_prefix
    spell_group_box = {
        --<span style="color:#6699CC;">English</span>: Delete Selected Spell Group<br><span style="color:#6699CC;">简体中文</span>: 删除所选法术组合<br><span style="color:#6699CC;">日本語</span>: 選択済みの呪文グループを削除<br><span style="color:#6699CC;">한국어</span>: 선택된 주문 그룹 삭제<br>
        ---@type tr.key
        delete = {},
        --<span style="color:#6699CC;">English</span>: Load Selected Spell Group Into Held Wand<br><span style="color:#6699CC;">简体中文</span>: 加载所选法术组合至法杖<br><span style="color:#6699CC;">日本語</span>: 選択済みの呪文グループを手持ちの杖にロード<br><span style="color:#6699CC;">한국어</span>: 선택된 주문 그룹을 손에 든 완드로 로드<br>
        ---@type tr.key
        load = {},
        --<span style="color:#6699CC;">English</span>: Save Selected Spells As A Group<br><span style="color:#6699CC;">简体中文</span>: 保存所选法术为组合<br><span style="color:#6699CC;">日本語</span>: 選択済みの呪文をグループとして保存<br><span style="color:#6699CC;">한국어</span>: 선택된 주문들을 그룹으로 저장<br>
        ---@type tr.key
        save = {},
        --<span style="color:#6699CC;">English</span>: Left-click to select this spell group<br><span style="color:#6699CC;">简体中文</span>: 左键选择该法术组合<br><span style="color:#6699CC;">日本語</span>: 左クリックでこの呪文グループを選択<br><span style="color:#6699CC;">한국어</span>: 왼쪽 클릭으로 이 주문 그룹을 선택<br>
        ---@type tr.key
        select = {},
    },
    --<span style="color:#6699CC;">English</span>: Spell Picker<br><span style="color:#6699CC;">简体中文</span>: 选取法术<br><span style="color:#6699CC;">日本語</span>: 呪文セレクター<br><span style="color:#6699CC;">한국어</span>: 주문 선택기<br>
    ---@class tr.keys.spell_picker: tr.key, tr.key_prefix
    spell_picker = {
        --<span style="color:#6699CC;">English</span>: %s added to your inventory<br><span style="color:#6699CC;">简体中文</span>: 法术 %s 已放入你的物品栏<br><span style="color:#6699CC;">日本語</span>: %sがインベントリに追加されました<br><span style="color:#6699CC;">한국어</span>: %s 인벤토리에 추가됨<br>
        ---@type tr.key
        action_added_to_inventory = {},
        --<span style="color:#6699CC;">English</span>: Quick Spell Picker<br><span style="color:#6699CC;">简体中文</span>: 快速装填<br><span style="color:#6699CC;">日本語</span>: クイック呪文セレクター<br><span style="color:#6699CC;">한국어</span>: 빠른 주문 선택기<br>
        ---@type tr.key
        quick_spell_picker = {},
        --<span style="color:#6699CC;">English</span>: Tips: %s to relock an unlocked spell<br><span style="color:#6699CC;">简体中文</span>: 提示：%s可重新锁定已解锁的法术<br><span style="color:#6699CC;">日本語</span>: ヒント：%sを押して解禁された呪文を再封印<br><span style="color:#6699CC;">한국어</span>: 팁: 잠금 해제된 주문을 다시 잠그려면 %s<br>
        ---@type tr.key
        relock_tips = {},
        --<span style="color:#6699CC;">English</span>: Search Spells by ID..<br><span style="color:#6699CC;">简体中文</span>: 搜索法术 ID..<br><span style="color:#6699CC;">日本語</span>: IDで検索..<br><span style="color:#6699CC;">한국어</span>: ID로 검색..<br>
        ---@type tr.key
        searchbox = {},
        --<span style="color:#6699CC;">English</span>: Show Locked Spells<br><span style="color:#6699CC;">简体中文</span>: 显示未解锁法术<br><span style="color:#6699CC;">日本語</span>: 未解禁呪文を表示<br><span style="color:#6699CC;">한국어</span>: 잠긴 주문 보기<br>
        ---@type tr.key
        show_locked_spells = {},
        --<span style="color:#6699CC;">English</span>: Inv & Nearby<br><span style="color:#6699CC;">简体中文</span>: 背包&附近<br><span style="color:#6699CC;">日本語</span>: 所持&付近<br><span style="color:#6699CC;">한국어</span>: 인벤&주변<br>
        ---@type tr.key
        tab_in_inv = {},
        --<span style="color:#6699CC;">English</span>: Recently Used<br><span style="color:#6699CC;">简体中文</span>: 最近使用<br><span style="color:#6699CC;">日本語</span>: 最近使用<br><span style="color:#6699CC;">한국어</span>: 최근 사용<br>
        ---@type tr.key
        tab_recent = {},
        --<span style="color:#6699CC;">English</span>: Tips: %s to clear<br><span style="color:#6699CC;">简体中文</span>: 提示: %s清空<br><span style="color:#6699CC;">日本語</span>: ヒント: %sを押して消去<br><span style="color:#6699CC;">한국어</span>: 팁: 지우려면 %s<br>
        ---@type tr.key
        tab_recent_tips = {},
        --<span style="color:#6699CC;">English</span>: Search Spells<br><span style="color:#6699CC;">简体中文</span>: 搜索法术<br><span style="color:#6699CC;">日本語</span>: 呪文検索<br><span style="color:#6699CC;">한국어</span>: 주문 검색<br>
        ---@type tr.key
        tab_search = {},
        --<span style="color:#6699CC;">English</span>: Spells By Type<br><span style="color:#6699CC;">简体中文</span>: 所有法术<br><span style="color:#6699CC;">日本語</span>: タイプ別<br><span style="color:#6699CC;">한국어</span>: 유형별 주문<br>
        ---@type tr.key
        tab_types = {},
        --<span style="color:#6699CC;">English</span>: 0 Uses<br><span style="color:#6699CC;">简体中文</span>: 初始使用次数归零<br><span style="color:#6699CC;">日本語</span>: 使用回数0で呪文を使用する<br><span style="color:#6699CC;">한국어</span>: 사용 횟수 0인 상태로 사용<br>
        ---@type tr.key
        zero_uses = {},
    },
    ---@class target_dummy: tr.key_prefix
    target_dummy = {
        --<span style="color:#6699CC;">English</span>: Average DPS<br><span style="color:#6699CC;">简体中文</span>: 平均 DPS<br><span style="color:#6699CC;">日本語</span>: 平均DPS<br><span style="color:#6699CC;">한국어</span>: 평균 DPS<br>
        ---@type tr.key
        average_dps = {},
        --<span style="color:#6699CC;">English</span>: DPS<br><span style="color:#6699CC;">简体中文</span>: DPS<br><span style="color:#6699CC;">日本語</span>: DPS<br><span style="color:#6699CC;">한국어</span>: DPS<br>
        ---@type tr.key
        dps = {},
        --<span style="color:#6699CC;">English</span>: Press $0 to remove this dummy target<br><span style="color:#6699CC;">简体中文</span>: 按 $0 删除假人<br><span style="color:#6699CC;">日本語</span>: $0を押してこのダミーを消去<br><span style="color:#6699CC;">한국어</span>: $0를 눌러 이 더미를 제거<br>
        ---@type tr.key
        entity_interact = {},
        --<span style="color:#6699CC;">English</span>: Highest DPS<br><span style="color:#6699CC;">简体中文</span>: 最高 DPS<br><span style="color:#6699CC;">日本語</span>: 最高DPS<br><span style="color:#6699CC;">한국어</span>: 최고 DPS<br>
        ---@type tr.key
        highest_dps = {},
        --<span style="color:#6699CC;">English</span>: Most Recent Damage<br><span style="color:#6699CC;">简体中文</span>: 最近一次伤害<br><span style="color:#6699CC;">日本語</span>: 直近のダメージ<br><span style="color:#6699CC;">한국어</span>: 가장 최근 대미지<br>
        ---@type tr.key
        last_frame_damage = {},
        --<span style="color:#6699CC;">English</span>: Those numbers are: <br><span style="color:#6699CC;">简体中文</span>: 所显示数字的含义分别为：<br><span style="color:#6699CC;">日本語</span>: 数字の意味：<br><span style="color:#6699CC;">한국어</span>: 다음 숫자들의 뜻:<br>
        ---@type tr.key
        numbers_are = {},
        --<span style="color:#6699CC;">English</span>: Spawn Target Dummy\nRight-click to spawn boss target dummy<br><span style="color:#6699CC;">简体中文</span>: 生成伤害测试假人\n右键生成 Boss 级伤害测试假人<br><span style="color:#6699CC;">日本語</span>: ダミーを召喚\n右クリックでボスダミーを召喚<br><span style="color:#6699CC;">한국어</span>: 더미를 소환\n오른쪽 클릭으로 보스 더미를 소환<br>
        ---@type tr.key
        tooltip = {},
        --<span style="color:#6699CC;">English</span>: Total Damage<br><span style="color:#6699CC;">简体中文</span>: 总伤害<br><span style="color:#6699CC;">日本語</span>: 合計ダメージ<br><span style="color:#6699CC;">한국어</span>: 총 대미지<br>
        ---@type tr.key
        total_damage = {},
    },
    ---@class terrain_spell_lab: tr.key_prefix
    terrain_spell_lab = {
        --<span style="color:#6699CC;">English</span>: Right-click to fix spell lab<br><span style="color:#6699CC;">简体中文</span>: 右键修复法术实验室<br><span style="color:#6699CC;">日本語</span>: 右クリックでスペルラボを修理<br><span style="color:#6699CC;">한국어</span>: 오른쪽 클릭으로 스펠 랩을 수리<br>
        ---@type tr.key
        desc = {},
        --<span style="color:#6699CC;">English</span>: Enter the Spell Lab<br><span style="color:#6699CC;">简体中文</span>: 进入法术实验室<br><span style="color:#6699CC;">日本語</span>: スペルラボ入場<br><span style="color:#6699CC;">한국어</span>: 스펠 랩 입장하기<br>
        ---@type tr.key
        enter = {},
        --<span style="color:#6699CC;">English</span>: Leave the Spell Lab\nShift + Left-click to return to the mines intrance<br><span style="color:#6699CC;">简体中文</span>: 离开法术实验室\nShift + 左键返回矿井入口<br><span style="color:#6699CC;">日本語</span>: スペルラボ退場\nShift + 左クリックで鉱山の入り口に戻る<br><span style="color:#6699CC;">한국어</span>: 스펠 랩 떠나기\nShift + 왼쪽 클릭으로 광산 입구로 돌아가기<br>
        ---@type tr.key
        leave = {},
        --<span style="color:#6699CC;">English</span>: Press [E] to fix spell lab<br><span style="color:#6699CC;">简体中文</span>: 按 [E] 修复法术实验室<br><span style="color:#6699CC;">日本語</span>: [E]を押してスペルラボを修理<br><span style="color:#6699CC;">한국어</span>: [E]를 눌러 스펠 랩을 수리<br>
        ---@type tr.key
        reloader_interact = {},
    },
    --<span style="color:#6699CC;">English</span>: Toggle Options<br><span style="color:#6699CC;">简体中文</span>: 开关类选项<br><span style="color:#6699CC;">日本語</span>: オプションを切り替え<br><span style="color:#6699CC;">한국어</span>: 옵션 전환<br>
    ---@type tr.key
    toggles_toggle = {},
    ---@class twwe_and_nwt: tr.key_prefix
    twwe_and_nwt = {
        --<span style="color:#6699CC;">English</span>: Gain one %s effect<br><span style="color:#6699CC;">简体中文</span>: 获得一层%s效果<br><span style="color:#6699CC;">日本語</span>: %s効果を一つ獲得<br><span style="color:#6699CC;">한국어</span>: %s 효과 하나 획득<br>
        ---@type tr.key
        gain = {},
        --<span style="color:#6699CC;">English</span>: Your current wand editing level is %s<br><span style="color:#6699CC;">简体中文</span>: 你当前的法杖编辑等级为 %s<br><span style="color:#6699CC;">日本語</span>: 現在の杖編集レベルは %s<br><span style="color:#6699CC;">한국어</span>: 현재 완드 편집 레벨은 %s<br>
        ---@type tr.key
        level = {},
        --<span style="color:#6699CC;">English</span>: Right-click to lose one %s effect<br><span style="color:#6699CC;">简体中文</span>: 右键失去一层%s效果<br><span style="color:#6699CC;">日本語</span>: 右クリックで%s効果を一つ消去<br><span style="color:#6699CC;">한국어</span>: 오른쪽 클릭으로 %s 효과 하나 제거<br>
        ---@type tr.key
        lose = {},
        --<span style="color:#6699CC;">English</span>: You have %s(from this mod) + %s(external) %s effect(s)<br><span style="color:#6699CC;">简体中文</span>: 当前你拥有 %s(来自此功能) + %s(其他来源) 层%s效果<br><span style="color:#6699CC;">日本語</span>: 現在 %s(このmod由来) + %s(その他) %s効果を所持中<br><span style="color:#6699CC;">한국어</span>: 현재 %s(이 모드로부터) + %s(그 외) %s 효과 보유 중<br>
        ---@type tr.key
        num = {},
        --<span style="color:#6699CC;">English</span>: NWT<br><span style="color:#6699CC;">简体中文</span>: 无法编辑魔杖<br><span style="color:#6699CC;">日本語</span>: 杖工作なし<br><span style="color:#6699CC;">한국어</span>: 완개없<br>
        ---@type tr.key
        nwt = {},
        ---@class twwe_and_nwt.result: tr.key_prefix
        result = {
            --<span style="color:#6699CC;">English</span>: You can edit wands everywhere<br><span style="color:#6699CC;">简体中文</span>: 你可以随时编辑魔杖<br><span style="color:#6699CC;">日本語</span>: どこにいても杖を編集できます<br><span style="color:#6699CC;">한국어</span>: 어디서나 완드를 편집할 수 있습니다<br>
            ---@type tr.key
            everywhere = {},
            --<span style="color:#6699CC;">English</span>: You can't edit wands<br><span style="color:#6699CC;">简体中文</span>: 你无法编辑魔杖<br><span style="color:#6699CC;">日本語</span>: 杖を編集できません<br><span style="color:#6699CC;">한국어</span>: 완드를 편집할 수 없습니다<br>
            ---@type tr.key
            unable = {},
            --<span style="color:#6699CC;">English</span>: You can only edit wands in workshops(i.e. holy mountains)<br><span style="color:#6699CC;">简体中文</span>: 你可以在圣山中编辑魔杖<br><span style="color:#6699CC;">日本語</span>: 編集が可能な場所に限り編集できます（聖なる山など）<br><span style="color:#6699CC;">한국어</span>: 편집 가능 장소에서만 완드를 편집할 수 있습니다 (예: 신성한 산)<br>
            ---@type tr.key
            workshop = {},
        },
        --<span style="color:#6699CC;">English</span>: TWWE<br><span style="color:#6699CC;">简体中文</span>: 随时编辑魔杖<br><span style="color:#6699CC;">日本語</span>: どこ杖<br><span style="color:#6699CC;">한국어</span>: 어완개<br>
        ---@type tr.key
        twwe = {},
    },
    --<span style="color:#6699CC;">English</span>: Wand Box<br><span style="color:#6699CC;">简体中文</span>: 法杖仓库<br><span style="color:#6699CC;">日本語</span>: 杖ボックス<br><span style="color:#6699CC;">한국어</span>: 완드 박스<br>
    ---@class tr.keys.wand_box: tr.key, tr.key_prefix
    wand_box = {
        --<span style="color:#6699CC;">English</span>: Current: %s / %s<br><span style="color:#6699CC;">简体中文</span>: 当前： %s / %s<br><span style="color:#6699CC;">日本語</span>: 現在： %s / %s<br><span style="color:#6699CC;">한국어</span>: 현재: %s / %s<br>
        ---@type tr.key
        current_page = {},
        --<span style="color:#6699CC;">English</span>: Delete Selected Wand<br><span style="color:#6699CC;">简体中文</span>: 删除所选法杖<br><span style="color:#6699CC;">日本語</span>: 選択した杖を削除<br><span style="color:#6699CC;">한국어</span>: 선택된 완드 삭제<br>
        ---@type tr.key
        delete = {},
        --<span style="color:#6699CC;">English</span>: Delete Page %s<br><span style="color:#6699CC;">简体中文</span>: 删除第 %s 页<br><span style="color:#6699CC;">日本語</span>: ページ %sを削除<br><span style="color:#6699CC;">한국어</span>: 페이지 %s 삭제하기<br>
        ---@type tr.key
        delete_page = {},
        --<span style="color:#6699CC;">English</span>: %s + Left-click to confirm deletion\nLeft-click again to cancel deletion<br><span style="color:#6699CC;">简体中文</span>: %s + 点击 确认删除\n再次点击取消<br><span style="color:#6699CC;">日本語</span>: %s + 左クリックで削除を確定\nもう一度左クリックして削除を取り消し<br><span style="color:#6699CC;">한국어</span>: %s + 왼쪽 클릭으로 삭제 확정\n왼쪽 클릭을 다시 하여 삭제 취소<br>
        ---@type tr.key
        deletion_confirm_button = {},
        --<span style="color:#6699CC;">English</span>: Hold %s to show wand stats<br><span style="color:#6699CC;">简体中文</span>: 按住 %s 显示法杖属性<br><span style="color:#6699CC;">日本語</span>: %sを押して杖の能力値を確認<br><span style="color:#6699CC;">한국어</span>: 완드 스탯을 보려면 %s<br>
        ---@type tr.key
        hold_something_to_show_wand_stats = {},
        --<span style="color:#6699CC;">English</span>: Previous Page<br><span style="color:#6699CC;">简体中文</span>: 上一页<br><span style="color:#6699CC;">日本語</span>: 前のページ<br><span style="color:#6699CC;">한국어</span>: 이전 페이지<br>
        ---@type tr.key
        last_page = {},
        --<span style="color:#6699CC;">English</span>: Load Selected Wand Into Held Wand<br><span style="color:#6699CC;">简体中文</span>: 加载所选法杖至手持法杖<br><span style="color:#6699CC;">日本語</span>: 選択した杖を手持ちにロード<br><span style="color:#6699CC;">한국어</span>: 선택된 완드를 손에 로드<br>
        ---@type tr.key
        load_to_hand = {},
        --<span style="color:#6699CC;">English</span>: Load Selected Wand Into World<br><span style="color:#6699CC;">简体中文</span>: 生成所选法杖<br><span style="color:#6699CC;">日本語</span>: 選択した杖をワールドにロード<br><span style="color:#6699CC;">한국어</span>: 선택된 완드를 세계에 로드<br>
        ---@type tr.key
        load_to_world = {},
        --<span style="color:#6699CC;">English</span>: Create New Page<br><span style="color:#6699CC;">简体中文</span>: 新建仓库页<br><span style="color:#6699CC;">日本語</span>: 新しいページを作成<br><span style="color:#6699CC;">한국어</span>: 새 페이지 만들기<br>
        ---@type tr.key
        new_page = {},
        --<span style="color:#6699CC;">English</span>: Next Page<br><span style="color:#6699CC;">简体中文</span>: 下一页<br><span style="color:#6699CC;">日本語</span>: 次のページ<br><span style="color:#6699CC;">한국어</span>: 다음 페이지<br>
        ---@type tr.key
        next_page = {},
        --<span style="color:#6699CC;">English</span>: No Previous Page<br><span style="color:#6699CC;">简体中文</span>: 已在第一页<br><span style="color:#6699CC;">日本語</span>: 前のページなし<br><span style="color:#6699CC;">한국어</span>: 이전 페이지 없음<br>
        ---@type tr.key
        no_last_page = {},
        --<span style="color:#6699CC;">English</span>: No Next Page<br><span style="color:#6699CC;">简体中文</span>: 已在最后一页<br><span style="color:#6699CC;">日本語</span>: 次のページなし<br><span style="color:#6699CC;">한국어</span>: 다음 페이지 없음<br>
        ---@type tr.key
        no_next_page = {},
        --<span style="color:#6699CC;">English</span>: No Wand Selected<br><span style="color:#6699CC;">简体中文</span>: 当前没有选中法杖<br><span style="color:#6699CC;">日本語</span>: 杖が選択されていません<br><span style="color:#6699CC;">한국어</span>: 완드가 선택되지 않았습니다<br>
        ---@type tr.key
        no_wand_selected = {},
        --<span style="color:#6699CC;">English</span>: Save Held Wand<br><span style="color:#6699CC;">简体中文</span>: 保存手持法杖<br><span style="color:#6699CC;">日本語</span>: 手持ちの杖を保存<br><span style="color:#6699CC;">한국어</span>: 손에 든 완드 저장<br>
        ---@type tr.key
        save = {},
        --<span style="color:#6699CC;">English</span>: The number of wands on this page has reached the maximum of 100<br><span style="color:#6699CC;">简体中文</span>: 本页法杖数量已达上限<br><span style="color:#6699CC;">日本語</span>: このページの杖の数が上限の100個に達しました<br><span style="color:#6699CC;">한국어</span>: 이 페이지의 완드 수가 최대치인 100개에 도달했습니다.<br>
        ---@type tr.key
        save_reached_page_limit = {},
    },
    --<span style="color:#6699CC;">English</span>: Clear Held Wand<br><span style="color:#6699CC;">简体中文</span>: 清空当前法杖<br><span style="color:#6699CC;">日本語</span>: 手持ちの杖を空にする<br><span style="color:#6699CC;">한국어</span>: 손에 든 완드 비우기<br>
    ---@type tr.key
    wand_clear = {},
    --<span style="color:#6699CC;">English</span>: Wand Edit Panel<br><span style="color:#6699CC;">简体中文</span>: 法杖编辑面板<br><span style="color:#6699CC;">日本語</span>: 杖編集パネル<br><span style="color:#6699CC;">한국어</span>: 완드 편집 패널<br>
    ---@class tr.keys.wand_edit_panel: tr.key, tr.key_prefix
    wand_edit_panel = {
        --<span style="color:#6699CC;">English</span>: Automatic Capacity<br><span style="color:#6699CC;">简体中文</span>: 自动调整容量<br><span style="color:#6699CC;">日本語</span>: 自動容量調整<br><span style="color:#6699CC;">한국어</span>: 자동 용량 조정<br>
        ---@class tr.keys.wand_edit_panel.automatic_capacity: tr.key, tr.key_prefix
        automatic_capacity = {
            --<span style="color:#6699CC;">English</span>: When enabled, the number of slots in the wand edit panel\nis not limited by the actual capacity of the wand\nNote: If there are no spells in the wand, the wand's capacity will be adjusted to 0,\nmaking the wand not shown in the vanilla inventory.\nThis is normal, just continue to edit the wand with automatic capacity enabled.<br><span style="color:#6699CC;">简体中文</span>: 开启时，法杖编辑面板按最大行数显示，同时法杖的实际容量自动调整至恰好容下其中法术\n注意：如果法杖中没有法术，法杖的容量会被调整为0，使之无法在原版背包中显示\n此为正常现象，继续使用自动调整容量编辑法杖即可<br><span style="color:#6699CC;">日本語</span>: 有効にした場合、杖編集パネル内のスロット数は\n杖の実際の容量に制限されません。\n注意：杖に呪文がいない場合、杖の容量が0に調整され、\nバニラのインベントリで杖が表示されなくなります。\nこれは正常で、自動容量調整を有効にしたまま杖の編集を続けてください。<br><span style="color:#6699CC;">한국어</span>: 기능을 켠 경우, 완드 편집 패널의 슬롯 수는\n완드의 실제 용량에 제한을 받지 않음.\n참고: 완드에 주문이 없는 경우, 완드의 용량이 0으로 조정되어\n기본 인벤토리에 완드가 표시되지 않음.\n이는 정상적인 현상이므로, 자동 용량 조정 기능을 활성화한 상태로 완드 편집을 계속하면 됨.<br>
            ---@type tr.key
            desc = {},
        },
        --<span style="color:#6699CC;">English</span>: Nothing To Redo<br><span style="color:#6699CC;">简体中文</span>: 无操作可供恢复<br><span style="color:#6699CC;">日本語</span>: やり直せるものなし<br><span style="color:#6699CC;">한국어</span>: 다시 실행할 것이 없음<br>
        ---@type tr.key
        cant_redo = {},
        --<span style="color:#6699CC;">English</span>: Nothing To Undo<br><span style="color:#6699CC;">简体中文</span>: 无操作可供撤销<br><span style="color:#6699CC;">日本語</span>: 取り消せるものなし<br><span style="color:#6699CC;">한국어</span>: 실행 취소할 것이 없음<br>
        ---@type tr.key
        cant_undo = {},
        --<span style="color:#6699CC;">English</span>: Current: %s / %s<br><span style="color:#6699CC;">简体中文</span>: 当前：%s / %s<br><span style="color:#6699CC;">日本語</span>: 現在：%s / %s<br><span style="color:#6699CC;">한국어</span>: 현재: %s / %s<br>
        ---@type tr.key
        current_history = {},
        --<span style="color:#6699CC;">English</span>: Current: %s / %s<br><span style="color:#6699CC;">简体中文</span>: 当前：第 %s / %s 行<br><span style="color:#6699CC;">日本語</span>: 現在：%s / %s<br><span style="color:#6699CC;">한국어</span>: 현재: %s / %s<br>
        ---@type tr.key
        current_row = {},
        --<span style="color:#6699CC;">English</span>: Current: %s<br><span style="color:#6699CC;">简体中文</span>: 当前：第 %s 行<br><span style="color:#6699CC;">日本語</span>: 現在：%s<br><span style="color:#6699CC;">한국어</span>: 현재: %s<br>
        ---@type tr.key
        current_row_autocap = {},
        --<span style="color:#6699CC;">English</span>: Spell Demotion Failed: No space for the demoted spell in wand<br><span style="color:#6699CC;">简体中文</span>: 取消始终施放失败：法杖中没有空间放置法术<br><span style="color:#6699CC;">日本語</span>: 呪文降格失敗：杖に降格対象の呪文用の空きがありません<br><span style="color:#6699CC;">한국어</span>: 주문 강등 실패: 완드에 강등시키려는 주문에 대한 공간이 없음<br>
        ---@type tr.key
        demotion_no_space = {},
        --<span style="color:#6699CC;">English</span>: Right-click to disable Replay Mode<br><span style="color:#6699CC;">简体中文</span>: 右键关闭回放模式<br><span style="color:#6699CC;">日本語</span>: 右クリックでリプレイモードを無効化<br><span style="color:#6699CC;">한국어</span>: 오른쪽 클릭으로 리플레이 모드 끄기<br>
        ---@type tr.key
        gif_mode_disable = {},
        --<span style="color:#6699CC;">English</span>: Right-click to enable Replay Mode<br><span style="color:#6699CC;">简体中文</span>: 右键开启回放模式<br><span style="color:#6699CC;">日本語</span>: 右クリックでリプレイモードを有効化<br><span style="color:#6699CC;">한국어</span>: 오른쪽 클릭으로 리플레이 모드 켜기<br>
        ---@type tr.key
        gif_mode_enable = {},
        --<span style="color:#6699CC;">English</span>: Spell Insertion Failed: No enough space in wand<br><span style="color:#6699CC;">简体中文</span>: 插入法术失败：法杖中没有足够的空间<br><span style="color:#6699CC;">日本語</span>: 呪文挿入失敗：杖に空きがありません<br><span style="color:#6699CC;">한국어</span>: 주문 삽입 실패: 완드에 공간이 없음<br>
        ---@type tr.key
        no_enough_space = {},
        --<span style="color:#6699CC;">English</span>: Redo<br><span style="color:#6699CC;">简体中文</span>: 恢复<br><span style="color:#6699CC;">日本語</span>: やり直し：<br><span style="color:#6699CC;">한국어</span>: 다시 실행: <br>
        ---@type tr.key
        redo = {},
        --<span style="color:#6699CC;">English</span>: %s to select this slot<br><span style="color:#6699CC;">简体中文</span>: %s选择该法术槽<br><span style="color:#6699CC;">日本語</span>: %sを押してこのスロットを選択<br><span style="color:#6699CC;">한국어</span>: 이 슬롯을 선택하려면 %s<br>
        ---@type tr.key
        spell_box_commmon_tips = {},
        --<span style="color:#6699CC;">English</span>: %s to deselect this slot<br><span style="color:#6699CC;">简体中文</span>: %s取消选择该法术槽<br><span style="color:#6699CC;">日本語</span>: %sを押してこのスロットの選択を解除<br><span style="color:#6699CC;">한국어</span>: 이 슬롯을 선택 해제하려면 %s<br>
        ---@type tr.key
        spell_box_commmon_tips_selected = {},
        --<span style="color:#6699CC;">English</span>: %s to demote this spell<br><span style="color:#6699CC;">简体中文</span>: %s以取消始终施放<br><span style="color:#6699CC;">日本語</span>: %sを押してこの呪文を降格<br><span style="color:#6699CC;">한국어</span>: 이 주문을 강등시키려면 %s<br>
        ---@type tr.key
        spell_box_permanent_tips = {},
        --<span style="color:#6699CC;">English</span>: Undo<br><span style="color:#6699CC;">简体中文</span>: 撤销<br><span style="color:#6699CC;">日本語</span>: 取り消し：<br><span style="color:#6699CC;">한국어</span>: 실행 취소: <br>
        ---@type tr.key
        undo = {},
    },
    --<span style="color:#6699CC;">English</span>: No Shooting<br><span style="color:#6699CC;">简体中文</span>: 禁止法杖射击<br><span style="color:#6699CC;">日本語</span>: 射撃無効<br><span style="color:#6699CC;">한국어</span>: 사격 무효<br>
    ---@class tr.keys.wand_no_shooting: tr.key, tr.key_prefix
    wand_no_shooting = {
        --<span style="color:#6699CC;">English</span>: Please disable No Shooting option before using wands<br><span style="color:#6699CC;">简体中文</span>: 使用法杖前请先关闭禁止法杖射击选项<br><span style="color:#6699CC;">日本語</span>: 杖を使用する前に射撃無効を無効にしてください<br><span style="color:#6699CC;">한국어</span>: 완드를 사용하기 전에 사격 무효를 꺼 주세요<br>
        ---@type tr.key
        cast_is_blocked = {},
    },
    --<span style="color:#6699CC;">English</span>: Wand Picker<br><span style="color:#6699CC;">简体中文</span>: 法杖生成器<br><span style="color:#6699CC;">日本語</span>: 杖セレクター<br><span style="color:#6699CC;">한국어</span>: 완드 선택기<br>
    ---@class tr.keys.wand_picker: tr.key, tr.key_prefix
    wand_picker = {
        --<span style="color:#6699CC;">English</span>: [Copy Held Wand]<br><span style="color:#6699CC;">简体中文</span>: [复制手持法杖]<br><span style="color:#6699CC;">日本語</span>: [手持ちの杖をコピー]<br><span style="color:#6699CC;">한국어</span>: [손에 든 완드 복사]<br>
        ---@type tr.key
        copy_held_wand = {},
        --<span style="color:#6699CC;">English</span>: The capacity you are setting for your wand is not enough for holding the spells in it. Hold %s and click again to confirm.<br><span style="color:#6699CC;">简体中文</span>: 当前设置的法杖容量不足以容纳法杖中法术，若仍要继续，请按住 %s 并再次点击<br><span style="color:#6699CC;">日本語</span>: 設定しようとしている杖の容量が、中にある呪文の数を下回ります。%sを押したままもう一度クリックして確定します。<br><span style="color:#6699CC;">한국어</span>: 설정하려는 완드 용량은 주문을 담기에 충분하지 않습니다. 확인하려면 %s 키를 누르고 다시 클릭하세요.<br>
        ---@type tr.key
        exploding_actions = {},
        --<span style="color:#6699CC;">English</span>: [%sPrecise Mode]<br><span style="color:#6699CC;">简体中文</span>: [%s精确调整]<br><span style="color:#6699CC;">日本語</span>: [%s精密モード]<br><span style="color:#6699CC;">한국어</span>: [%s정밀 모드]<br>
        ---@class tr.keys.wand_picker.precise_mode: tr.key, tr.key_prefix
        precise_mode = {
            --<span style="color:#6699CC;">English</span>: Tips: Left/right clicking on a value increases/decreases the stat by the value<br><span style="color:#6699CC;">简体中文</span>: 提示：左键/右键点击数值可以使相应的属性增加/减少这个数值<br><span style="color:#6699CC;">日本語</span>: ヒント：値を左/右クリックするとその値の分だけ能力値が増加/減少します<br><span style="color:#6699CC;">한국어</span>: 팁: 값을 왼쪽/오른쪽 클릭하면 스탯이 그 값만큼 증가/감소함<br>
            ---@type tr.key
            tips = {},
        },
        --<span style="color:#6699CC;">English</span>: [Spawn]<br><span style="color:#6699CC;">简体中文</span>: [生成法杖]<br><span style="color:#6699CC;">日本語</span>: [杖生成]<br><span style="color:#6699CC;">한국어</span>: [생성]<br>
        ---@type tr.key
        spawn_wand = {},
        --<span style="color:#6699CC;">English</span>: [Update Held Wand]<br><span style="color:#6699CC;">简体中文</span>: [更新手持法杖]<br><span style="color:#6699CC;">日本語</span>: [手持ちの杖をアップデート]<br><span style="color:#6699CC;">한국어</span>: [손에 든 완드 업데이트]<br>
        ---@type tr.key
        update_held_wand = {},
    },
    --<span style="color:#6699CC;">English</span>: Clear Cast Delay / Recharge Time<br><span style="color:#6699CC;">简体中文</span>: 清除当前施放延迟/充能时间<br><span style="color:#6699CC;">日本語</span>: 詠唱遅延/リチャージ時間をリセット<br><span style="color:#6699CC;">한국어</span>: 시전 딜레이 / 충전 시간 초기화<br>
    ---@class tr.keys.wand_ready: tr.key, tr.key_prefix
    wand_ready = {
        --<span style="color:#6699CC;">English</span>: The cast delays of your wands are fixed to %s\nThe reload times of your wands are fixed to %s\nRight-click to unfix them<br><span style="color:#6699CC;">简体中文</span>: 施放延迟已锁定为 %s\n充能时间已锁定为 %s\n右击取消锁定<br><span style="color:#6699CC;">日本語</span>: 杖の詠唱遅延が%sに固定されています\n杖のリチャージ時間が%sにに固定されています\n右クリックで固定を解除<br><span style="color:#6699CC;">한국어</span>: 완드의 시전 딜레이가 %s(으)로 고정됨\n완드의 충전 시간이 %s으(로) 고정됨\n오른쪽 클릭으로 고정을 해제<br>
        ---@type tr.key
        cast_delay_fixed_to = {},
        --<span style="color:#6699CC;">English</span>: Shift + Left-click to fix cast delay & recharge time to the values of held wand\nShift + Right-click to fix cast delay & recharge time to 0\nAlt + click to fix cast delay & recharge time of all wands to their raw values<br><span style="color:#6699CC;">简体中文</span>: Shift + 左键锁定施放延迟/充能时间为当前法杖数值\nShift + 右键锁定施放延迟/充能时间为 0\nAlt + 点击锁定所有法杖施放延迟/充能时间为其面板原始值<br><span style="color:#6699CC;">日本語</span>: Shift + 左クリックで詠唱遅延とリチャージ時間を手持ちの杖のものに固定\nShift + 右クリックで詠唱遅延とリチャージ時間を0に固定\nAlt + クリックで、すべての杖の詠唱遅延とリチャージ時間をそれぞれの元の値に固定<br><span style="color:#6699CC;">한국어</span>: Shift + 왼쪽 클릭으로 시전 딜레이 및 충전 시간을 손에 든 완드의 값으로 고정\nShift + 오른쪽 클릭으로 시전 딜레이 및 충전 시간을 0으로 설정\nAlt + 클릭으로 모든 완드의 시전 딜레이 및 충전 시간을 완드 기본값으로 고정<br>
        ---@type tr.key
        desc = {},
        --<span style="color:#6699CC;">English</span>: Raw value of wand<br><span style="color:#6699CC;">简体中文</span>: 法杖原始值<br><span style="color:#6699CC;">日本語</span>: 杖の基本能力値<br><span style="color:#6699CC;">한국어</span>: 완드의 기본값<br>
        ---@type tr.key
        wand_raw_value = {},
    },
}
