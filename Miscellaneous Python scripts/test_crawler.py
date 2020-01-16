from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

driver = webdriver.Chrome(ChromeDriverManager().install())
driver.implicitly_wait(15)

driver.get("https://itch.io/jam/techkids-code-for-viet-nam-2018/entries")
# driver.find_element(By.XPATH,"//a[@class='toggle_info_btn']").click()
# time.sleep(2)
# WebDriverWait(driver, 3).until(
#     EC.presence_of_element_located(
        # (By.XPATH, "//div[@class='game_info_panel_widget']/table//tr//td"))) #Wait for specific element 

# games = driver.find_elements(By.CSS_SELECTOR, ".title").getText()
games = driver.find_elements_by_class_name('label')
print(len(games))
for game in games:
    print(game.text)

driver.quit()