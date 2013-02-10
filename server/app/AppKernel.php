<?php

use Symfony\Component\HttpKernel\Kernel;
use Symfony\Component\Config\Loader\LoaderInterface;

class AppKernel extends Kernel
{
	public function registerBundles()
	{
		$bundles = array(
			new Symfony\Bundle\FrameworkBundle\FrameworkBundle(),
			new Symfony\Bundle\SecurityBundle\SecurityBundle(),
			new Symfony\Bundle\TwigBundle\TwigBundle(),
			new Symfony\Bundle\MonologBundle\MonologBundle(),
			new Symfony\Bundle\SwiftmailerBundle\SwiftmailerBundle(),
			new Symfony\Bundle\AsseticBundle\AsseticBundle(),
			new Doctrine\Bundle\DoctrineBundle\DoctrineBundle(),
			new FOS\UserBundle\FOSUserBundle(),
			new Stof\DoctrineExtensionsBundle\StofDoctrineExtensionsBundle(),
			new Sensio\Bundle\FrameworkExtraBundle\SensioFrameworkExtraBundle(),
			new JMS\AopBundle\JMSAopBundle(),
			new JMS\DiExtraBundle\JMSDiExtraBundle($this),
			new JMS\SecurityExtraBundle\JMSSecurityExtraBundle(),
			
			
			//Menu
            new Knp\Bundle\MenuBundle\KnpMenuBundle(),

            //Pager
            new WhiteOctober\PagerfantaBundle\WhiteOctoberPagerfantaBundle(),

            //Generator
            new Admingenerator\GeneratorBundle\AdmingeneratorGeneratorBundle(),
            new Admingenerator\UserBundle\AdmingeneratorUserBundle(),

            //Doctrine
            new Doctrine\Bundle\FixturesBundle\DoctrineFixturesBundle(),

			// Nicky Digital
			new NickyDigital\PhotoboothBundle\NickyDigitalPhotoboothBundle(),
            new NickyDigital\PhotoboothAdminBundle\NickyDigitalPhotoboothAdminBundle(),
		);

		if (in_array($this->getEnvironment(), array('dev', 'test'))) {
			$bundles[] = new Symfony\Bundle\WebProfilerBundle\WebProfilerBundle();
			$bundles[] = new Sensio\Bundle\DistributionBundle\SensioDistributionBundle();
			$bundles[] = new Sensio\Bundle\GeneratorBundle\SensioGeneratorBundle();
		}

		return $bundles;
	}

	public function registerContainerConfiguration(LoaderInterface $loader)
	{
		$loader->load(__DIR__ . '/config/config_' . $this->getEnvironment() . '.yml');
	}
}
